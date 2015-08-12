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

  @type t :: %__MODULE__{product_name: String.t, plan_tree: PlanTreeNode.t}

  @doc """
  Method to convert a map into a Workflow struct

  ## Options

  The `payload` option defines the Map containing the Workflow

  ## Return Values

  OpenAperture.WorkflowOrchestratorApi.Workflow
  """
  @spec from_payload(map) :: t
  def from_payload(payload) do
    %__MODULE__{
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
  @spec to_payload(t) :: map
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

  @spec determine_current_step(PlanTreeNode.t) :: PlanTreeNode.t | nil
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

  @spec update_current_step_status(PlanTreeNode.t | nil, PlanTreeNode.t, term) :: PlanTreeNode.t | nil
  def update_current_step_status(nil, _parent, _new_status) do 
    nil
  end

  @spec update_current_step_status(PlanTreeNode.t, term) :: PlanTreeNode.t | nil
  def update_current_step_status(root, status) do 
    update_current_step_status(root, %PlanTreeNode{status: "success"}, "success", status)
  end

  @spec update_current_step_status(PlanTreeNode.t, PlanTreeNode.t, String.t, term) :: PlanTreeNode.t | nil
  defp update_current_step_status(root, parent, step_case, new_status) do 
    success_child = nil
    failure_child = nil

    status = case {root.status, parent.status, step_case} do
      {nil, "success", "success"} -> 
        new_status
      {nil, "failure", "failure"} -> 
        new_status
      {"in_progress", _, _} -> 
        new_status
      _ ->
        root.status
    end

    if root.on_success_step_id do
      success_child = update_current_step_status(root.on_success_step, root, "success", new_status)
    end

    if root.on_failure_step_id do
      failure_child = update_current_step_status(root.on_failure_step, root, "failure", new_status)
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
    current_output_text = Poison.decode!(response.body["output"])
    appended_output_text = current_output_text ++ deployment.output

    deployment_update = %{output: Poison.encode!(appended_output_text), completed: deployment.completed}
    _response = DeploymentApi.update_deployment(ManagerApi.get_api(), deployment.product_name, deployment.deployment_id, deployment_update)
  end

end