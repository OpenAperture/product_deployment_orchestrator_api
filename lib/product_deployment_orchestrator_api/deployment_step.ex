require Logger

defmodule OpenAperture.ProductDeploymentOrchestratorApi.DeploymentStep do

  use Timex

  @moduledoc """
  Methods and Workflow struct that will be received from (and should be sent to) the WorkflowOrchestrator
  """
  alias OpenAperture.ManagerApi
  alias OpenAperture.ManagerApi.ProductDeploymentStep, as: ProductDeploymentStepApi

  defstruct id: nil,
            product_deployment_id: nil,
            product_name: nil,
            duration: nil,
            output: nil,
            successful: nil,
            updated_at: nil

  @type t :: %__MODULE__{id: String.t, product_deployment_id: String.t, product_name: String.t, duration: String.t, output: list, successful: boolean, updated_at: Timex.Date.t}

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
      id: payload[:id],
      product_deployment_id: payload[:product_deployment_id],
      product_name: payload[:product_name],
      duration: payload[:duration],
      output: payload[:output],
      successful: payload[:successful],
      updated_at: parse_datetime_from_map(payload[:updated_at])
    }
  end

  def from_response_body(payload, product_name) do 
    updated_at = Enum.into(Map.keys(payload["updated_at"]), %{}, fn key -> {String.to_atom(key), payload["updated_at"][key]} end)

    %__MODULE__{
      id: payload["id"],
      product_deployment_id: payload["product_deployment_id"],
      product_name: product_name,
      duration: payload["duration"],
      output: [],
      successful: payload["successful"],
      updated_at: parse_datetime_from_map(updated_at)
    }
  end 

  @spec from_payload(map) :: t
  def from_payload(nil) do
    nil
  end

  @doc """
  Method to convert a Workflow struct into a map

  ## Options

  The `workflow` option defines the OpenAperture.WorkflowOrchestratorApi.Workflow

  ## Return Values

  Map
  """
  @spec to_payload(t) :: map
  def to_payload(deployment_step) do
    %{
      id: deployment_step.id,
      product_deployment_id: deployment_step.product_deployment_id,
      product_name: deployment_step.product_name,
      duration: deployment_step.duration,
      output: deployment_step.output,
      successful: deployment_step.successful,
      updated_at: parse_datetime_into_map(deployment_step.updated_at)
    }
  end

  defp parse_datetime_from_map(datetime) do 
    Date.from({{datetime[:year], datetime[:month], datetime[:day]}, {datetime[:hour], datetime[:min], datetime[:sec]}})
  end 

  defp parse_datetime_into_map(datetime) do 
    %{year: datetime.year, month: datetime.month, day: datetime.day, hour: datetime.hour, min: datetime.minute, sec: datetime.second}
  end 

  defp calculate_duration(updated_at, duration) do 
    duration_delta = Date.diff(updated_at, Date.now, :secs)
    duration + duration_delta
  end 

  def save(deployment_step) do 
    response = ProductDeploymentStepApi.get_step(ManagerApi.get_api(), deployment_step.product_name, deployment_step.product_deployment_id, deployment_step.id)

    #Append logs
    current_output_text = Poison.decode!(response.body["output"])
    appended_output_text = current_output_text ++ deployment_step.output

    #Update durationd 
    duration = calculate_duration(deployment_step.updated_at, Integer.parse(response.body["duration"]) |> (fn {duration, _} -> duration end).())

    deployment_step_update = %{output: Poison.encode!(appended_output_text), successful: deployment_step.successful, duration: Integer.to_string(duration)}
    response = ProductDeploymentStepApi.update_step(ManagerApi.get_api(), deployment_step.product_name, deployment_step.product_deployment_id, deployment_step.id, deployment_step_update)
    deployment_step = %{ deployment_step | duration: duration}
    %{ deployment_step | updated_at: Date.now}
  end

end