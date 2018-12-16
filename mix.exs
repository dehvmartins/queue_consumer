defmodule QueueConsumer.MixProject do
  use Mix.Project

  def project do
    [
      app: :queue_consumer,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.json": :test,
        "coveralls.html": :test,
        "coveralls.travis": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_aws, "~> 2.0"},
      {:ex_aws_sqs, github: "ex-aws/ex_aws_sqs", ref: "185ec5b0ffa09ba2ca0f69ec73bda3a23f5c55f3"},
      {:sweet_xml, "~> 0.6"},
      {:gen_stage, "~> 0.14"},
      {:hackney, "~> 1.14"},
      {:certifi, "~> 2.4"},
      {:excoveralls, "~> 0.8", only: :test},
      {:mox, "~> 0.4.0", only: :test},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: :dev, runtime: false}
    ]
  end
end
