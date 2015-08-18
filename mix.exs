defmodule OpenAperture.ProductDeploymentOrchestratorApi.Mixfile do
  use Mix.Project

  def project do
    [app: :openaperture_product_deployment_orchestrator_api,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: { OpenAperture.ProductDeploymentOrchestratorApi, [] },
      applications: [
        :logger, 
        :openaperture_messaging, 
        :openaperture_manager_api,
        :openaperture_fleet
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:ex_doc, "0.7.3", only: :test},
      {:earmark, "0.1.17", only: :test},
      
      {:poison, "~> 1.3.1", override: true},
      {:openaperture_messaging, git: "https://github.com/OpenAperture/messaging.git", ref: "3d3a84eabf4ba0a3a827a61c4d99cdbf0ab49a0d", override: true},
      {:openaperture_manager_api, git: "https://github.com/OpenAperture/manager_api.git", ref: "7bee243e9ae57938b09799ac01a9edc2f722720c", override: true},
      {:openaperture_fleet, git: "https://github.com/OpenAperture/fleet.git", ref: "e6bdda3822e8d9c6a382366fbdbbd9238e3a48db", override: true},
      
      {:fleet_api, "~> 0.0.4"},
      {:timex, "~> 0.12.9"},
      {:timex_extensions, git: "https://github.com/OpenAperture/timex_extensions.git", ref: "904f65f7f9f5d4e52619859e886c2e9a73b96bc0", override: true},

      #test dependencies
      {:exvcr, github: "parroty/exvcr", override: true},
      {:meck, "0.8.2", override: true}
    ]
  end
end
