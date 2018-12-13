defmodule QueueConsumerTest do
  use ExUnit.Case
  doctest QueueConsumer

  test "greets the world" do
    assert QueueConsumer.hello() == :world
  end
end
