defmodule QueueConsumer do
  @moduledoc """
  Quick and easy way to consume messages from a queue.

  Sets up a [GenStage](https://github.com/elixir-lang/gen_stage) Producer with a ConsumerSupervisor.

  All you need to do is implement the `QueueConsumer.Processor` behaviour, and pass in your configuration.
  A task will be spawned to handle each message that is received from the queue.

  Currently only comes with an adapter for AWS's Simple Queue Service, but only two callbacks need to be implemented
  in order to add a new adapter. See `QueueConsumer.Queue`.

  Just add `QueueConsumer` to your application's supervision tree, passing in a list of queue configurations, ie:
  ```
  children = [
    {QueueConsumer, queue_consumer_config}
  ]
  ```

  ## Configuration
  - :queues -- List of queue configurations
  - :name -- (Optional) name for the top level supervisor

  ### Queue Configuration
  - :processor_mod -- The module name of your `QueueConsumer.Processor` behaviour implementation
  - :queue_mod -- (Optional) The module name of the queue adapter you wish to use, defaults to `QueueConsumer.Queue.Sqs`
  - :queue_opts -- (Optional) Keyword list of options specific to the queue adapter, defaults to `[]`
  - :name -- (Optional) Name prefix for the Producer and ConsumerSupervisor. NOTE: This option is REQUIRED if you pass in more than one queue config, ie you want to consumer more than one queue.

  An example queue configuration for an SQS queue would look something like:
  ```
  queue_consumer_config = [
    [
      queue_mod: QueueConsumer.Queue.Sqs,
      queue_opts: [queue_name: "my-sqs-queue-name"],
      processor_mod: MyApp.MessageProcessor,
      name: :my_queue_processor
    ]
  ]
  ```
  Note: `:name` is only required if you plan to consume more than one queue in your application.
  """

  use Supervisor

  alias QueueConsumer.Producer
  alias QueueConsumer.Consumer

  @type queue_config :: [
          queue_mod: module(),
          queue_opts: Keyword.t(),
          processor_mod: module(),
          name: atom()
        ]

  @type queue_consumer_opts :: [
          name: atom(),
          queues: [queue_config()]
        ]

  @spec start_link(queue_consumer_opts) :: {:ok, pid} | {:error, term} | :ignore
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: args[:name] || __MODULE__)
  end

  @impl true
  def init(args) do
    args
    |> children()
    |> Supervisor.init([strategy: :one_for_one])
  end

  defp children(args) do
    Keyword.get(args, :queues, [])
    |> Enum.map(fn queue ->
      [
        Supervisor.child_spec({Producer, queue}, id: name(queue[:name], :queue_consumer_producer)),
        Supervisor.child_spec({Consumer, queue}, id: name(queue[:name], :queue_consumer_consumer))
      ]
    end)
    |> List.flatten()
  end

  @doc false
  def name(nil, type), do: type
  def name(name, type), do: String.to_atom("#{name}_#{type}")
end
