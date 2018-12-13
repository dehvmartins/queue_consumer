# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :queue_consumer, aws_mod: ExAws

import_config "#{Mix.env()}.exs"
