defmodule QueueConsumer.Consumer do
  @moduledoc false
  use ConsumerSupervisor

  def start_link(args) do
    ConsumerSupervisor.start_link(__MODULE__, args,
      name: QueueConsumer.name(args[:name], :queue_consumer_consumer)
    )
  end

  def init(args) do
    queue_mod = Keyword.get(args, :queue_mod)
    queue_opts = Keyword.get(args, :queue_opts, [])
    processor = Keyword.get(args, :processor_mod)
    max_demand = Keyword.get(args, :max_demand, 10)
    min_demand = Keyword.get(args, :min_demand, 1)

    children = [
      %{
        id: processor,
        start: {processor, :start_link, [queue_mod, queue_opts]},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [
        {QueueConsumer.name(args[:name], :queue_consumer_producer),
         max_demand: max_demand, min_demand: min_demand}
      ]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
