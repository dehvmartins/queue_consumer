defmodule QueueConsumer.Producer do
  use GenStage

  require Logger

  def start_link(args) do
    GenStage.start_link(__MODULE__, args,
      name: QueueConsumer.name(args[:name], :queue_consumer_producer)
    )
  end

  def init(args) do
    state = %{
      demand: 0,
      queue: Keyword.get(args, :queue_mod),
      opts: Keyword.get(args, :queue_opts, [])
    }

    {:producer, state}
  end

  def handle_demand(incoming_demand, %{demand: 0} = state) do
    new_demand = state.demand + incoming_demand
    Process.send(self(), :get_messages, [])
    {:noreply, [], %{state | demand: new_demand}}
  end

  def handle_demand(incoming_demand, state) do
    new_demand = state.demand + incoming_demand
    {:noreply, [], %{state | demand: new_demand}}
  end

  def handle_info(:get_messages, state) do
    opts =
      Keyword.merge(
        state.opts,
        max_number_of_messages: min(state.demand, 10)
      )

    messages =
      case state.queue.dequeue(opts) do
        {:ok, msgs} ->
          msgs

        {:error, reason} ->
          Logger.warn("error fetching messages from queue\n#{inspect(reason)}")
          []
      end

    num_messages_received = Enum.count(messages)
    new_demand = max(state.demand - num_messages_received, 0)

    cond do
      new_demand == 0 ->
        :ok

      num_messages_received == 0 ->
        Process.send_after(self(), :get_messages, 200)

      true ->
        Process.send(self(), :get_messages, [])
    end

    {:noreply, messages, %{state | demand: new_demand}}
  end
end
