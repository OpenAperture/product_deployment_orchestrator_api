require Logger

defmodule OpenAperture.ProductDeploymentOrchestratorApi.ProductDeploymentOrchestrator.Publisher do
  use GenServer

  @moduledoc """
  This module contains the logic to publish messages to the WorkflowOrchestrator system module
  """  

  alias OpenAperture.ManagerApi

  alias OpenAperture.Messaging.AMQP.QueueBuilder
  alias OpenAperture.Messaging.ConnectionOptionsResolver

  alias OpenAperture.ManagerApi
  alias OpenAperture.ProductDeploymentOrchestratorApi.Request
  alias OpenAperture.ProductDeploymentOrchestratorApi.Deployment 
  alias OpenAperture.ProductDeploymentOrchestratorApi.PlanTreeNode

  @connection_options nil
  use OpenAperture.Messaging

  @doc """
  Specific start_link implementation (required by the supervisor)

  ## Options

  ## Return Values

  {:ok, pid} | {:error, reason}
  """
  @spec start_link() :: {:ok, pid} | {:error, String.t}   
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Method to publish to the WorkflowOrchestrator

  ## Options

  The `request` option defines the `OpenAperture.WorkflowOrchestratorApi.Request`

  ## Return Values

  :ok | {:error, reason}   
  """
  @spec execute_orchestration(Request.t) :: :ok | {:error, String.t}
  def execute_orchestration(request) do
    GenServer.cast(__MODULE__, {:execute_orchestration, request})
  end

  #OpenAperture.ProductDeploymentOrchestratorApi.ProductDeploymentOrchestrator.Publisher.send_test_message()
  def send_test_message() do 
    request = %Request{
      product_deployment_orchestration_exchange_id: 1,
      product_deployment_orchestration_broker_id: 1,
      product_deployment_orchestration_queue: "product_deployment_orchestrator",
      deployment: %Deployment{
        product_name: "product1",
        deployment_id: 101,
        plan_tree: %PlanTreeNode{
          type: "build_deploy",
          options: %{},
          execution_options: %{},
          on_success_step_id: 1,
          on_success_step: %PlanTreeNode{
            type: "build_deploy",
            options: %{},
            execution_options: %{},
            on_success_step_id: nil,
            on_success_step: nil,
            on_failure_step_id: nil,
            on_failure_step: nil,
            status: nil
          },
          on_failure_step_id: 2,
          on_failure_step: %PlanTreeNode{
            type: "build_deploy",
            options: %{},
            execution_options: %{},
            on_success_step_id: nil,
            on_success_step: nil,
            on_failure_step_id: nil,
            on_failure_step: nil,
            status: nil
          },
          status: nil
        },
        completed: false,
      },
      step_info: %{}
    }
    GenServer.cast(__MODULE__, {:execute_orchestration, request})
  end

  @doc """
  Call handler to publish to the WorkflowOrchestrator

  ## Options

  The `request` option defines the `OpenAperture.WorkflowOrchestratorApi.Request`

  The `_from` option defines the tuple {from, ref}

  The `state` option represents the server's current state
  
  ## Return Values

  {:reply, {messaging_exchange_id, machine}, resolved_state}
  """
  @spec handle_cast({:execute_orchestration, Request.t}, map) :: {:noreply, map}
  def handle_cast({:execute_orchestration, request}, state) do
    product_deployment_orchestration_queue = QueueBuilder.build(ManagerApi.get_api, request.product_deployment_orchestration_queue, request.product_deployment_orchestration_exchange_id)
    Logger.debug("queue struct: #{inspect product_deployment_orchestration_queue}")
    options = ConnectionOptionsResolver.get_for_broker(ManagerApi.get_api, request.product_deployment_orchestration_broker_id)
    payload = Request.to_payload(request)
    Logger.debug("[ProductDeploymentOrchestratorApi][Publisher] payload: #{inspect payload}")
    Logger.debug("[ProductDeploymentOrchestratorApi][Publisher] Attemping to publish...")
    case publish(options, product_deployment_orchestration_queue, payload) do
      :ok -> Logger.debug("[ProductDeploymentOrchestratorApi][Publisher] Successfully published to the ProductDeploymentOrchestrator queue")
      {:error, reason} -> Logger.error("[ProductDeploymentOrchestratorApi][Publisher] Failed to publish to the ProductDeploymentOrchestrator:  #{inspect reason}")
    end
    {:noreply, state}
  end
end