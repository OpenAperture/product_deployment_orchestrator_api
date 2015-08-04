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
      {:ex_doc, github: "elixir-lang/ex_doc", only: [:test]},
      {:markdown, github: "devinus/markdown", only: [:test]},
      
      {:poison, "~> 1.3.1", override: true},
      {:openaperture_messaging, git: "https://github.com/OpenAperture/messaging.git", ref: "584353928f56777227ff0d70277ba25ceff725ab", override: true},
      {:openaperture_manager_api, git: "https://github.com/OpenAperture/manager_api.git", ref: "5b9e88b7aa00763a89b459ba8b24e83e62785a8a", override: true},
      {:openaperture_fleet, git: "https://github.com/OpenAperture/fleet.git", ref: "7aeca4655225fa0dd63f1465c0af30b0992b94b5", override: true},
      
      {:fleet_api, "~> 0.0.4"},
      {:timex, "~> 0.12.9"},
      {:timex_extensions, git: "https://github.com/OpenAperture/timex_extensions.git", ref: "904f65f7f9f5d4e52619859e886c2e9a73b96bc0", override: true},

      #test dependencies
      {:exvcr, github: "parroty/exvcr", override: true},
      {:meck, "0.8.2", override: true}
    ]
  end
end