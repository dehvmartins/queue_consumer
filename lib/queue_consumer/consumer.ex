defmodule QueueConsumer.Consumer do
  use ConsumerSupervisor

  alias QueueConsumer.Producer
  alias QueueConsumer.Queue.Sqs, as: Queue

  def start_link(args) do
    ConsumerSupervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    queue_mod = Keyword.get(args, :queue_mod, Queue)
    queue_opts = Keyword.get(args, :queue_opts, [])
    processor = Keyword.get(args, :processor_mod)
    max_demand = Keyword.get(args, :max_demand, 10)

    children = [
      %{
        id: processor,
        start: {processor, :start_link, [queue_mod, queue_opts]},
        restart: :transient
      }
    ]

    opts = [strategy: :one_for_one, subscribe_to: [{Producer, max_demand: max_demand}]]
    ConsumerSupervisor.init(children, opts)
  end
end
