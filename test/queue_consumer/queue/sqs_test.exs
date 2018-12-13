defmodule QueueConsumer.Queue.SqsTest do
  use ExUnit.Case, async: true

  import Mox

  alias QueueConsumer.Queue.Sqs

  @opts [
    queue_name: "fake-queue-name",
    visibility_timeout: 30,
    max_number_of_messages: 1,
    wait_time_seconds: 20
  ]

  setup :verify_on_exit!

  describe "dequeue/1" do
    test "successful" do
      message = "do work"

      ExAwsMock
      |> expect(:request, fn _ -> dequeue_response(message) end)

      assert {:ok, [{_handle, ^message}]} = Sqs.dequeue(@opts)
    end

    test "empty queue" do
      ExAwsMock
      |> expect(:request, fn _ -> empty_dequeue_response() end)

      assert {:ok, []} = Sqs.dequeue(@opts)
    end

    test "error" do
      reason = "error response"

      ExAwsMock
      |> expect(:request, fn _ -> {:error, reason} end)

      assert {:error, ^reason} = Sqs.dequeue(@opts)
    end
  end

  describe "mark_as_done/2" do
    test "successful" do
      ExAwsMock
      |> expect(:request, fn _ -> mark_as_done_response() end)

      assert {:ok, true} = Sqs.mark_as_done("msg_id_123", @opts)
    end

    test "error" do
      reason = "error response"

      ExAwsMock
      |> expect(:request, fn _ -> {:error, reason} end)

      assert {:error, ^reason} = Sqs.mark_as_done("msg_id_123", @opts)
    end
  end

  defp receipt_handle do
    "AQEB9u5RZZtQtAymrLlxcog/GfUdFQJmwkVZVas+zyLgFunKkxV4wX12ryR6D28u2IkuRashc1dq1TW3q+PDWXs19BvmPsFkch2YceXXlXfaf5Nywku11bhbOgGzVZ17NLuJZwAga3VDiUhyh7TOicV4LvTbUYpJfHvhlfc8dqN9YMhH3p5n2PAfd064FLpj8P/Yt8idIKXRW/0V7AXvLbipCJjKNPNEpeWi/jmPELQJvM7RZ1ZY2VqH7+A/NJcEqQzW4pJCivNPH5uIRtEPwptHM0WfHKhBTWMVBEc5omCLrgIs/ruQAe9JXEJw77DoWS8KomY+iNTL0Oovs6c0UaUwHP+6jx1uT+vfkYAT83tuoXc1ao3vzbCnmrxCPZptwPTTfFNQQ10NzQTziDkQnagC5Q=="
  end

  defp dequeue_response(message) do
    {:ok,
     %{
       body: %{
         messages: [
           %{
             attributes: [],
             body: message,
             md5_of_body: "619dcf02658513b889c4c7be5dd9cec8",
             message_attributes: [],
             message_id: "d36ed92c-2e7d-4914-87a8-ab57b2545209",
             receipt_handle: receipt_handle()
           }
         ],
         request_id: "65119458-6b20-53e7-b7fe-c04b5e293125"
       },
       headers: [
         {"x-amzn-RequestId", "65119458-6b20-53e7-b7fe-c04b5e293125"},
         {"Content-Type", "text/xml"},
         {"Content-Length", "985"}
       ],
       status_code: 200
     }}
  end

  defp empty_dequeue_response do
    {:ok,
     %{
       body: %{
         messages: [],
         request_id: "65119458-6b20-53e7-b7fe-c04b5e293125"
       },
       headers: [
         {"x-amzn-RequestId", "65119458-6b20-53e7-b7fe-c04b5e293125"},
         {"Content-Type", "text/xml"},
         {"Content-Length", "985"}
       ],
       status_code: 200
     }}
  end

  defp mark_as_done_response do
    {:ok,
     %{
       body: %{request_id: "4e0118cd-330d-5707-a92b-4cde066ea23f"},
       headers: [
         {"Server", "Server"},
         {"Date", "Wed, 12 Sep 2018 15:39:15 GMT"},
         {"Content-Type", "text/xml"},
         {"Content-Length", "215"},
         {"Connection", "keep-alive"},
         {"x-amzn-RequestId", "4e0118cd-330d-5707-a92b-4cde066ea23f"}
       ],
       status_code: 200
     }}
  end
end
