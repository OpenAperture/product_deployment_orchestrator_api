defmodule OpenAperture.ProductDeploymentOrchestratorApi.Request do
  require Logger

  @moduledoc """
  Methods and Request struct that will be received from (and should be sent to) the WorkflowOrchestrator
  """
  
  alias OpenAperture.ProductDeploymentOrchestratorApi.Deployment
  alias OpenAperture.ProductDeploymentOrchestratorApi.DeploymentStep
  #alias OpenAperture.ProductDeploymentOrchestratorApi.PlanTreeNode

  defstruct deployment: nil, 
    deployment_step: nil,
    product_deployment_orchestration_queue: nil,
    product_deployment_orchestration_exchange_id: nil,
    product_deployment_orchestration_broker_id: nil,
    step_info: %{},
    delivery_tag: nil,
    completed: nil

  @type t :: %__MODULE__{}

  @doc """
  Method to convert a map into a Request struct

  ## Options

  The `payload` option defines the Map containing the request

  ## Return Values

  OpenAperture.WorkflowOrchestratorApi.Request.t
  """
  @spec from_payload(map) :: t
  def from_payload(payload) do
    %__MODULE__{
      deployment: Deployment.from_payload(payload[:deployment]),  
      deployment_step: DeploymentStep.from_payload(payload[:deployment_step]),
      product_deployment_orchestration_queue: payload[:product_deployment_orchestration_queue],
      product_deployment_orchestration_exchange_id: payload[:product_deployment_orchestration_exchange_id],
      product_deployment_orchestration_broker_id: payload[:product_deployment_orchestration_broker_id],
      step_info: payload[:step_info],
      delivery_tag: payload[:delivery_tag],
    }
  end

  @doc """
  Method to convert a Request struct into a map

  ## Options

  The `request` option defines the OpenAperture.WorkflowOrchestratorApi.Request.t

  ## Return Values

  Map
  """
  @spec to_payload(t) :: map
  def to_payload(request) do
    payload = if request.deployment != nil do 
      %{deployment: Deployment.to_payload(request.deployment)}
    else
      %{}
    end

    payload = if request.deployment_step != nil do 
      Map.put(payload, :deployment_step, DeploymentStep.to_payload(request.deployment_step))
    else
      Map.put(payload, :deployment_step, nil)
    end

    payload = Map.put(payload, :product_deployment_orchestration_queue, request.product_deployment_orchestration_queue)
    payload = Map.put(payload, :product_deployment_orchestration_exchange_id, request.product_deployment_orchestration_exchange_id)
    payload = Map.put(payload, :product_deployment_orchestration_broker_id, request.product_deployment_orchestration_broker_id)
    payload = Map.put(payload, :step_info, request.step_info)
    payload = Map.put(payload, :delivery_tag, request.delivery_tag)
    payload = Map.put(payload, :completed, request.completed)
    payload
  end
end