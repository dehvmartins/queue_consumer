defmodule QueueConsumer.Processor do
  @moduledoc """
  Implement this behaviour and reference the module's name in the queue config
  when you start the `QueueConsumer`.
  """

  @typedoc "An identifier, used to mark a job as complete"
  @type message_id :: binary()

  @type message_body :: binary()

  @type message :: {message_id(), message_body()}

  @typedoc "Queue adapter module"
  @type queue :: module()

  @typedoc "Options specific to the queue implementation"
  @type queue_opts :: Keyword.t()

  @doc """
  Called once for each message that is received.

  A typical implementation would look something like:
  ```
  def start_link(queue, queue_opts, {msg_id, msg}) do
    Task.start_link(fn ->
      case handle_message(msg) do
        {:ok, _} -> queue.mark_as_done(msg_id, queue_opts)
        # Error handling cases where you can decide whether you want to
        # mark the message as done, or leave it in the queue to be retried.
      end
    end)
  end
  ```
  """
  @callback start_link(queue(), queue_opts(), message()) ::
              {:ok, term()} | {:error, term()}
end
