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

  describe "enqueue/1" do
    test "can send a message to SQS" do
      message = "new message"

      expected_request =
        expected_request(
          %{
            "Action" => "SendMessage",
            "MessageBody" => "new message",
            "MaxNumberOfMessages" => 1,
            "QueueName" => "fake-queue-name",
            "VisibilityTimeout" => 30,
            "WaitTimeSeconds" => 20
          },
          :send_message
        )

      response = %{
        id: "778626b8-304f-4b01-b6ac-72e472f04778",
        md5_of_message_attributes: "",
        md5_of_message_body: "2e9252a4054b108edf3b3a10f5b63479",
        message_id: "685a6b79-d4d6-4d36-9280-1fb394b0b660"
      }

      ExAwsMock
      |> expect(:request, fn ^expected_request -> {:ok, %{body: response}} end)

      assert {:ok, _} = Sqs.enqueue(message, @opts)
    end

    test "returns error tuple when request fails" do
      ExAwsMock
      |> expect(:request, fn _ -> {:error, :failed} end)

      assert {:error, _} = Sqs.enqueue("meh", @opts)
    end
  end

  describe "dequeue/1" do
    test "can get a message from SQS" do
      message = "do work"

      ExAwsMock
      |> expect(:request, fn _ -> dequeue_response(message) end)

      assert {:ok, [{_handle, ^message}]} = Sqs.dequeue(@opts)
    end

    test "returns empty list when queue is empty" do
      ExAwsMock
      |> expect(:request, fn _ -> empty_dequeue_response() end)

      assert {:ok, []} = Sqs.dequeue(@opts)
    end

    test "returns error tuple when request returns an error" do
      reason = "error response"

      ExAwsMock
      |> expect(:request, fn _ -> {:error, reason} end)

      assert {:error, ^reason} = Sqs.dequeue(@opts)
    end
  end

  describe "mark_as_done/2" do
    test "sends delete message request to SSQS" do
      ExAwsMock
      |> expect(:request, fn _ -> mark_as_done_response() end)

      assert {:ok, true} = Sqs.mark_as_done("msg_id_123", @opts)
    end

    test "returns error tuple when request returns an error" do
      reason = "error response"

      ExAwsMock
      |> expect(:request, fn _ -> {:error, reason} end)

      assert {:error, ^reason} = Sqs.mark_as_done("msg_id_123", @opts)
    end
  end

  defp receipt_handle do
    "AQEB9u5RZZtQtAymrLlxcog/GfUdFQJmwkVZVas+zyLgFunKkxV4wX12ryR6D28u2IkuRashc1dq1TW3q+PDWXs19BvmPsFkch2YceXXlXfaf5Nywku11bhbOgGzVZ17NLuJZwAga3VDiUhyh7TOicV4LvTbUYpJfHvhlfc8dqN9YMhH3p5n2PAfd064FLpj8P/Yt8idIKXRW/0V7AXvLbipCJjKNPNEpeWi/jmPELQJvM7RZ1ZY2VqH7+A/NJcEqQzW4pJCivNPH5uIRtEPwptHM0WfHKhBTWMVBEc5omCLrgIs/ruQAe9JXEJw77DoWS8KomY+iNTL0Oovs6c0UaUwHP+6jx1uT+vfkYAT83tuoXc1ao3vzbCnmrxCPZptwPTTfFNQQ10NzQTziDkQnagC5Q=="
  end

  defp expected_request(params, action) do
    %ExAws.Operation.Query{
      action: action,
      params: params,
      parser: &ExAws.SQS.Parsers.parse/2,
      path: "/#{@opts[:queue_name]}",
      service: :sqs
    }
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
