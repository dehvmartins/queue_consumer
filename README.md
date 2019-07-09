### Note:
This was written before https://github.com/plataformatec/broadway existed. You should probably look at that now.

# QueueConsumer
[![Build Status](https://travis-ci.org/sneako/queue_consumer.svg?branch=master)](https://travis-ci.org/sneako/queue_consumer)
[![Coverage Status](https://coveralls.io/repos/github/sneako/queue_consumer/badge.svg?branch=master)](https://coveralls.io/github/sneako/queue_consumer?branch=master)

Quick and easy way to consume a message queue. Sets up a [GenStage](https://github.com/elixir-lang/gen_stage) Producer with
a ConsumerSupervisor. All you need to do is implement the `QueueConsumer.Processor` behaviour, and pass in your configuration.

## Installation
 
If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `queue_consumer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:queue_consumer, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/queue_consumer](https://hexdocs.pm/queue_consumer).

