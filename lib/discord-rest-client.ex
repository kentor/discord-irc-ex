defmodule DiscordIrcEx.DiscordRestClient do
  use GenServer
  alias DiscordEx.RestClient.Resources.Channel
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def send_msg(channel_id, msg) when is_integer(channel_id) do
    GenServer.cast(__MODULE__, {:send_msg_to_channel_id, channel_id, msg})
  end

  def init(_) do
    {:ok, conn} = DiscordEx.RestClient.start_link(%{
      token: "Bot #{Application.get_env(:discord_irc_ex, :discord_token)}",
    })
    Logger.debug("Discord Rest Client started")
    {:ok, %{conn: conn}}
  end

  def handle_cast({:send_msg_to_channel_id, channel_id, msg}, state) do
    Channel.send_message(state.conn, channel_id, %{content: msg})
    Logger.debug("Sent #{inspect(msg)} to channel #{channel_id}")
    {:noreply, state}
  end
end
