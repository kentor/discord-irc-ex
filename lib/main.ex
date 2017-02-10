defmodule DiscordIrcEx do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(DiscordIrcEx.DiscordClient, []),
      worker(DiscordIrcEx.DiscordRestClient, []),
      worker(DiscordIrcEx.IrcBot, []),
    ]

    opts = [strategy: :one_for_one, name: KpfBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
