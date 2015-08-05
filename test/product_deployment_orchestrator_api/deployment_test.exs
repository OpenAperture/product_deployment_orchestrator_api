defmodule OpenAperture.ProductDeploymentOrchestratorApi.DeploymentTest do
  use ExUnit.Case

  alias OpenAperture.ProductDeploymentOrchestratorApi.Deployment
  alias OpenAperture.ProductDeploymentOrchestratorApi.PlanTreeNode

  # setup_all do
  # end

  # setup do
  # end

  test "update_current_step_status -- nil" do 
    input = %PlanTreeNode{
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
    }

    updated_tree = Deployment.update_current_step_status(input, "in_progress")

    #Update occurred
    assert updated_tree.status == "in_progress"

    #Rest of tree is unaffected
    assert updated_tree.on_success_step.status == nil
  end

  test "update_current_step_status -- in progress" do 
    input = %PlanTreeNode{
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
      status: "in_progress"
    }

    updated_tree = Deployment.update_current_step_status(input, "success")

    #Update occured
    assert updated_tree.status == "success"

    #Rest of tree is unaffected
    assert updated_tree.on_success_step.status == nil
  end

  test "update_current_step_status -- update non top-level node" do 
    input = %PlanTreeNode{
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
      status: "success"
    }

    updated_tree = Deployment.update_current_step_status(input, "in_progress")

    #Update occured
    assert updated_tree.on_success_step.status == "in_progress"

    #Rest of tree is unaffected
    assert updated_tree.status == "success"
    assert updated_tree.on_failure_step.status == nil
  end

  
end
