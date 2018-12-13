defmodule QueueConsumer.Queue do
  @type message_id :: binary
  @type message_body :: binary
  @type message :: {message_id, message_body}

  @typedoc "Implementation specific options"
  @type opts :: Keyword.t()

  @doc "Pop a message off the queue"
  @callback dequeue(opts) :: {:ok, [message]} | {:error, term}

  @doc "Mark a consumed message as done/processed/complete"
  @callback mark_as_done(message_id, opts) :: {:ok, term} | {:error, term}
end
