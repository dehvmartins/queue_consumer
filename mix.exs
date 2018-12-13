defmodule QueueConsumer.MixProject do
  use Mix.Project

  def project do
    [
      app: :queue_consumer,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_aws, "~> 2.0", override: true},
      {:ex_aws_sqs, "~> 2.0"},
      {:sweet_xml, "~> 0.6"},
      {:gen_stage, "~> 0.14"},
      {:hackney, "~> 1.14"},
      {:excoveralls, "~> 0.8", only: :test},
      {:mox, "~> 0.4.0", only: :test}
    ]
  end
end
