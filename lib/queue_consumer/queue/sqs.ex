defmodule QueueConsumer.Queue.Sqs do
  @moduledoc """
  AWS [SQS](https://aws.amazon.com/sqs/) Adapter

  By default, it uses [long polling](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-long-polling.html) to minimize requests, but this is configurable via the `:wait_time_seconds` option.

  This adapter uses [ExAws](https://github.com/ex-aws/ex_aws) and [ExAws.Sqs](https://github.com/ex-aws/ex_aws_sqs) to interact with SQS.

  Be sure to configure ExAws either via AWS standard `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables or in your application's config:
  ```
  config :ex_aws,
    access_key_id: MY_AWS_KEY,
    secret_access_key: MY_AWS_SECRET
  ```
  See [ExAws](https://github.com/ex-aws/ex_aws) for all configuration options.

  ## Options:
    - :queue_name -- name of the SQS queue
    - :visibility_timeout -- (Optional) See [SQS Developer Guide](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html), defaults to `180` seconds
    - :wait_time_seconds -- (Optional) See [SQS Developer Guide](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-long-polling.html), defaults to `20`
    - :max_number_of_messages -- (Optional) maximum number of messages to get on each request, defaults to `1`, SQS has a hard limit of 10 messages at a time.
  """

  @behaviour QueueConsumer.Queue

  @type opts :: [
          queue_name: binary,
          visibility_timeout: non_neg_integer,
          max_number_of_message: pos_integer,
          wait_time_seconds: non_neg_integer
        ]

  alias ExAws.SQS

  require Logger

  @aws_mod Application.get_env(:queue_consumer, :aws_mod, ExAws)
  @max_batch_size 10

  @impl true
  def enqueue(msg, opts) do
    with queue_name when is_binary(queue_name) <- Keyword.get(opts, :queue_name),
         request <- SQS.send_message(queue_name, msg, opts),
         {:ok, %{body: res}} <- @aws_mod.request(request) do
      Logger.debug("enqueued 1 SQS message")
      {:ok, res}
    end
  end

  @impl true
  def dequeue(opts) do
    Logger.debug("requesting messages from SQS")

    sqs_opts = [
      visibility_timeout: opts[:visibility_timeout] || 180,
      wait_time_seconds: Keyword.get(opts, :wait_time_seconds, 20),
      max_number_of_messages: min(opts[:max_number_of_messages] || 1, @max_batch_size)
    ]

    with request <- SQS.receive_message(opts[:queue_name], sqs_opts),
         {:ok, %{body: %{messages: msgs}}} when is_list(msgs) <- @aws_mod.request(request) do
      {:ok, Enum.map(msgs, &extract_msg/1)}
    end
  end

  @impl true
  def mark_as_done(receipt_handle, opts) do
    with queue_name when is_binary(queue_name) <- Keyword.get(opts, :queue_name),
         request <- SQS.delete_message(queue_name, receipt_handle),
         {:ok, %{body: %{request_id: _}}} <- @aws_mod.request(request) do
      {:ok, true}
    end
  end

  defp extract_msg(%{body: msg, receipt_handle: id}), do: {id, msg}
end
