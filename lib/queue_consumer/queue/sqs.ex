defmodule QueueConsumer.Queue.Sqs do
  @behaviour QueueConsumer.Queue

  alias ExAws.SQS

  require Logger

  @max_batch_size 10

  @impl true
  def dequeue(args) do
    timeout = args[:visibility_timeout] || 180
    num_messages = args[:max_number_of_messages] || 1
    Logger.info("requesting messages from SQS")

    SQS.receive_message(
      args[:queue_name],
      visibility_timeout: timeout,
      wait_time_seconds: 20,
      max_number_of_messages: num_messages
    )
    |> ExAws.request()
    |> case do
      {:ok, %{body: %{messages: [_ | _] = msgs}}} ->
        out = Enum.map(msgs, &extract_msg/1)
        {:ok, out}

      {:ok, %{body: %{messages: []}}} ->
        Logger.info("#{args[:queue_name]} queue is empty")
        {:error, :empty_queue}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def mark_as_done(receipt_handle, queue_name: queue_name) do
    SQS.delete_message(queue_name, receipt_handle)
    |> ExAws.request()
    |> case do
      {:ok, %{body: %{request_id: _}}} ->
        {:ok, true}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp extract_msg(%{body: msg, receipt_handle: id}), do: {id, msg}

  defp extract_msg(msg) do
    Logger.warn("got invalid message #{inspect(msg)}")
    {nil, nil}
  end
end
