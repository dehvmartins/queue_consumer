defmodule QueueConsumer.Queue do
  @moduledoc """
  Queue adapter behaviour.
  """

  @type message_id :: binary()
  @type message_body :: binary()
  @type message :: {message_id(), message_body()}

  @typedoc "Implementation specific options"
  @type opts :: Keyword.t()

  @doc "Get messages from the queue"
  @callback dequeue(opts) :: {:ok, [message()]} | {:error, term()}

  @doc "Mark a consumed message as done/processed/complete"
  @callback mark_as_done(message_id(), opts()) :: {:ok, term()} | {:error, term()}

  @doc """
  Push a message to the queue.

  This is not used by `QueueConsumer`, but is provided in case your
  your implementation of `QueueConsumer.Processor` requires a new
  message to be enqueued as a result of a processed message.
  """
  @callback enqueue(message(), opts()) :: {:ok, term()} | {:error, term()}
  @optional_callbacks enqueue: 2
end
