defmodule QueueConsumer do
  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {QueueConsumer.Application, :start, [nil, args]}
    }
  end
end
