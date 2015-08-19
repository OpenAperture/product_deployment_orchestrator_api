defmodule OpenAperture.ProductDeploymentOrchestratorApi.PlanTreeNode do 

  defstruct id: nil, 
    type: nil,
    execution_options: %{},
    options: %{},
    on_success_step_id: nil,
    on_success_step: nil,
    on_failure_step_id: nil,
    on_failure_step: nil,
    status: nil

  @type t :: %__MODULE__{on_success_step: t, on_failure_step: t, status: String.t, execution_options: map, options: map}

  @doc """
  Method to convert a map into a Workflow struct

  ## Options

  The `payload` option defines the Map containing the Workflow

  ## Return Values

  OpenAperture.WorkflowOrchestratorApi.Workflow
  """
  @spec from_payload(map) :: t
  def from_payload(payload) do
    success_child = nil
    failure_child = nil

    if payload[:on_success_step_id] do
      success_child = from_payload(payload[:on_success_step])
    end

    if payload[:on_failure_step_id] do
      failure_child = from_payload(payload[:on_failure_step])
    end

    %__MODULE__{
      id: payload[:id],
      type: payload[:type],
      execution_options: payload[:execution_options],
      options: payload[:options],
      on_success_step_id: payload[:on_success_step_id],
      on_success_step: success_child,
      on_failure_step_id: payload[:on_failure_step_id],
      on_failure_step: failure_child,
      status: payload[:status]
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
  def to_payload(root) do
    success_child = nil
    failure_child = nil

    if root.on_success_step_id do
      success_child = to_payload(root.on_success_step)
    end

    if root.on_failure_step_id do
      failure_child = to_payload(root.on_failure_step)
    end


    %{
      id: root.id,
      type: root.type,
      execution_options: root.execution_options,
      options: root.options,
      on_success_step_id: root.on_success_step_id,
      on_success_step: success_child,
      on_failure_step_id: root.on_failure_step_id,
      on_failure_step: failure_child,
      status: root.status
    }
  end  
  
  
end