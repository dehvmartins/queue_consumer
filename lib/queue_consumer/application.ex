defmodule QueueConsumer.Application do
  @moduledoc false

  alias QueueConsumer.Producer
  alias QueueConsumer.Consumer

  use Application

  def start(_type, args) do
    IO.inspect(args, label: :queue_consumer_app_args)

    children = [
      {Producer, args},
      {Consumer, args}
    ]

    opts = [strategy: :one_for_one, name: QueueConsumer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
