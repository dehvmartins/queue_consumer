defmodule QueueConsumer.Processor do
  @typedoc "Used to mark a job as complete"
  @type message_id :: binary
  @type message_body :: binary
  @type message :: {message_id, message_body}

  @callback handle_message(message) :: {:ok, term} | {:error, term}
end
