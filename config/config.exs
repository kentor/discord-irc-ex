# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Create a "settings.exs"" file in this directory, with the following:
#
# use Mix.Config
# config :discord_irc_ex, [
#   channel_mapping: [
#     %{discord_channel_id: 268616433301323776, irc_channel: "#boji"},
#   ],
#   discord_token: "DISCORD_TOKEN",
#   irc_host: "irc server",
#   irc_nick: "nick",
#   irc_pass: "optional",
#   irc_port: 6667,
#   irc_user: "optional",
# ]
#

import_config "settings.exs"

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :discord_irc_ex, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:discord_irc_ex, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
