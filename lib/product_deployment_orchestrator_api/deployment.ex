require Logger

defmodule OpenAperture.ProductDeploymentOrchestratorApi.Deployment do

  @moduledoc """
  Methods and Workflow struct that will be received from (and should be sent to) the WorkflowOrchestrator
  """

  #alias OpenAperture.ProductDeploymentOrchestratorApi.Notifications.Publisher, as: NotificationsPublisher
  #alias OpenAperture.ProductDeploymentOrchestratorApi.ProductDeploymentOrchestrator.Publisher, as: WorkflowOrchestratorPublisher
  #alias OpenAperture.ProductDeploymentOrchestratorApi.Request
  alias OpenAperture.ProductDeploymentOrchestratorApi.PlanTreeNode
  alias OpenAperture.ManagerApi
  alias OpenAperture.ManagerApi.Deployment, as: DeploymentApi

  defstruct product_name: nil,
            deployment_id: nil,
            plan_tree: nil,
            output: nil,
            completed: false

  @type t :: %__MODULE__{}

  @doc """
  Method to convert a map into a Workflow struct

  ## Options

  The `payload` option defines the Map containing the Workflow

  ## Return Values

  OpenAperture.WorkflowOrchestratorApi.Workflow
  """
  @spec from_payload(Map) :: OpenAperture.WorkflowOrchestratorApi.Workflow
  def from_payload(payload) do
    %OpenAperture.ProductDeploymentOrchestratorApi.Deployment{
      product_name: payload[:product_name],
      deployment_id: payload[:deployment_id],
      plan_tree: PlanTreeNode.from_payload(payload[:plan_tree]),
      output: payload[:output],
      completed: payload[:completed]
    }
  end

  @doc """
  Method to convert a Workflow struct into a map

  ## Options

  The `workflow` option defines the OpenAperture.WorkflowOrchestratorApi.Workflow

  ## Return Values

  Map
  """
  @spec to_payload(OpenAperture.WorkflowOrchestratorApi.Workflow.t) :: Map
  def to_payload(deployment) do
    plan_tree = PlanTreeNode.to_payload(deployment.plan_tree)

    %{
      product_name: deployment.product_name,
      deployment_id: deployment.deployment_id,
      plan_tree: plan_tree,
      output: deployment.output,
      completed: deployment.completed
    }
  end

  def determine_current_step(nil) do 
    nil
  end 

  def determine_current_step(root) do 
    case root.status do 
      nil ->
        root
      "in_progress" ->
        root
      "success" ->
        determine_current_step(root.on_success_step)
      "failure" ->
        determine_current_step(root.on_failure_step)
    end
  end  

  def update_current_step_status(nil, _parent, _new_status) do 
    nil
  end

  def update_current_step_status(root, parent, new_status) do 
    success_child = nil
    failure_child = nil

    status = case {root.status, parent.status} do
      {nil, "success"} -> 
        new_status
      {nil, "failure"} -> 
        new_status
      {"in_progress", _} -> 
        new_status
      _ ->
        root.status
    end

    if root.on_success_step_id do
      success_child = update_current_step_status(root.on_success_step, root, new_status)
    end

    if root.on_failure_step_id do
      failure_child = update_current_step_status(root.on_failure_step, root, new_status)
    end

    %OpenAperture.ProductDeploymentOrchestratorApi.PlanTreeNode{
      type: root.type,
      execution_options: root.execution_options,
      options: root.options,
      on_success_step_id: root.on_success_step_id,
      on_success_step: success_child,
      on_failure_step_id: root.on_failure_step_id,
      on_failure_step: failure_child,
      status: status
    }
  end

  def save(deployment) do 
    response = DeploymentApi.get_deployment(ManagerApi.get_api(), deployment.product_name, deployment.deployment_id)
    Logger.debug("Response: #{inspect response}")
    current_output_text = Poison.decode!(response.body["output"])
    appended_output_text = current_output_text ++ deployment.output
    IO.puts(appended_output_text)

    deployment_update = %{output: Poison.encode!(appended_output_text), completed: deployment.completed}
    _response = DeploymentApi.update_deployment(ManagerApi.get_api(), deployment.product_name, deployment.deployment_id, deployment_update)
  end

end