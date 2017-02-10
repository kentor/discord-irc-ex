defmodule DiscordIrcEx.DiscordClient do
  use GenServer
  alias DiscordIrcEx.IrcColor
  alias DiscordIrcEx.IrcBot
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    DiscordEx.Client.start_link(%{
      handler: __MODULE__.Handler,
      token: Application.get_env(:discord_irc_ex, :discord_token),
    })

    Logger.debug("DiscordHandler started")

    {:ok, nil}
  end

  defmodule Handler do
    def handle_event({:message_create, payload}, state) do
      %{
        data: %{
          "author" => %{"id" => author_id, "username" => username},
          "channel_id" => channel_id,
          "content" => content,
        },
      } = payload

      if author_id != state.client_id && content != "" do
        msg = "<#{IrcColor.colorize(username)}> #{content}"
        IrcBot.relay_discord_to_irc(channel_id, msg)
      end

      {:ok, state}
    end

    def handle_event({_event, _payload}, state) do
      {:ok, state}
    end
  end
end
