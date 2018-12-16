defmodule QueueConsumerTest do
  use ExUnit.Case, async: true
  doctest QueueConsumer

  @max_wait 3_000

  defmodule MessageProcessor do
    @behaviour QueueConsumer.Processor
    def start_link(queue, queue_opts, {msg_id, _msg}) do
      Task.start_link(fn ->
        queue.mark_as_done(msg_id, queue_opts)
      end)
    end
  end

  defmodule GenericQueue do
    def dequeue(_opts) do
      msgs =
        [{"msg_id", "msg"}]
        |> Stream.cycle()
        |> Enum.take(:rand.uniform(3) - 1)

      {:ok, msgs}
    end

    def mark_as_done(_, self: pid, done_message: msg) do
      Process.send(pid, msg, [])
    end
  end

  test "call handle_message function when it receives a message" do
    queues = [
      name: :first,
      queues: [
        [
          queue_mod: GenericQueue,
          queue_opts: [self: self(), done_message: :first_test_complete],
          processor_mod: MessageProcessor
        ]
      ]
    ]

    assert {:ok, _pid} = QueueConsumer.start_link(queues)
    assert_receive :first_test_complete, @max_wait
  end

  test "can start multiple instances as long as they have different names" do
    queues = [
      name: :second,
      queues: [
        [
          name: :first_queue,
          queue_mod: GenericQueue,
          queue_opts: [self: self(), done_message: :first_queue_complete],
          processor_mod: MessageProcessor
        ],
        [
          name: :second_queue,
          queue_mod: GenericQueue,
          queue_opts: [self: self(), done_message: :second_queue_complete],
          processor_mod: MessageProcessor
        ]
      ]
    ]

    assert {:ok, _pid} = QueueConsumer.start_link(queues)
    assert_receive :first_queue_complete, @max_wait
    assert_receive :second_queue_complete, @max_wait
  end
end
