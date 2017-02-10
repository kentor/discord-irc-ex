defmodule DiscordIrcEx.IrcBot do
  use GenServer
  alias DiscordEx.RestClient.Resources.Channel
  alias DiscordIrcEx.DiscordRestClient
  alias ExIrc.Client
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def send_msg(channel, msg) do
    GenServer.cast(__MODULE__, {:send_msg, channel, msg})
  end

  def relay_discord_to_irc(discord_channel_id, msg) do
    GenServer.cast(__MODULE__, {:relay_discord_to_irc, discord_channel_id, msg})
  end

  def init(_) do
    discord_to_irc_mapping = Enum.reduce(
      Application.get_env(:discord_irc_ex, :channel_mapping),
      %{},
      fn(x, acc) -> Map.put(acc, x.discord_channel_id, x.irc_channel) end
    )

    irc_to_discord_mapping = Enum.reduce(
      Application.get_env(:discord_irc_ex, :channel_mapping),
      %{},
      fn(x, acc) -> Map.put(acc, x.irc_channel, x.discord_channel_id) end
    )

    {:ok, client} = ExIrc.start_client!()

    irc_host = Application.get_env(:discord_irc_ex, :irc_host)
    irc_port = Application.get_env(:discord_irc_ex, :irc_port, 6667)

    Client.add_handler(client, self())
    Client.connect!(client, irc_host, irc_port)

    {:ok, %{
      client: client,
      discord_to_irc_mapping: discord_to_irc_mapping,
      irc_to_discord_mapping: irc_to_discord_mapping,
    }}
  end

  def handle_cast({:send_msg, channel, msg}, state) do
    if Client.is_logged_on?(state.client) do
      :ok = resync(state, channel)
      :ok = Client.msg(state.client, :privmsg, channel, msg)
      Logger.debug("Sent #{msg} to #{channel}")
    else
      Logger.debug("Dropped message #{msg} for #{channel}")
    end
    {:noreply, state}
  end

  def handle_cast({:relay_discord_to_irc, discord_channel_id, msg}, state) do
    irc_channel = Map.get(state.discord_to_irc_mapping, discord_channel_id, nil)

    if irc_channel do
      handle_cast({:send_msg, irc_channel, msg}, state)
    end

    {:noreply, state}
  end

  def handle_info({:received, msg, %{nick: nick}, channel}, state) do
    discord_channel_id = Map.get(state.irc_to_discord_mapping, channel, nil)
    irc_nick = Application.get_env(:discord_irc_ex, :irc_nick)

    if discord_channel_id do
      msg = "**<#{nick}>** #{msg}"
      DiscordRestClient.send_msg(discord_channel_id, msg)
    end
    {:noreply, state}
  end

  def handle_info({:connected, server, port}, state) do
    Logger.debug("Connected to #{server}:#{port}")

    irc_pass = Application.get_env(:discord_irc_ex, :irc_pass, "")
    irc_nick = Application.get_env(:discord_irc_ex, :irc_nick)
    irc_user = Application.get_env(:discord_irc_ex, :irc_user, irc_nick)
    irc_name = Application.get_env(:discord_irc_ex, :irc_name, irc_nick)

    Client.logon(state.client, irc_pass, irc_nick, irc_user, irc_name)

    {:noreply, state}
  end

  def handle_info(:logged_in, state) do
    irc_nick = Application.get_env(:discord_irc_ex, :irc_nick)
    Logger.debug("Logged in as #{irc_nick}")
    :ok = resync(state)
    {:noreply, state}
  end

  def handle_info({_, "KICK", _}, state) do
    :ok = resync(state)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.debug(inspect(msg))
    {:noreply, state}
  end

  defp resync(state, channel \\ nil) do
    Logger.debug("resyncing...")

    irc_nick = Application.get_env(:discord_irc_ex, :irc_nick)
    :ok = Client.nick(state.client, irc_nick)
    Logger.debug("reset nick to #{irc_nick}")

    if channel do
      :ok = Client.join(state.client, channel)
      Logger.debug("Joined #{channel}")
    else
      for {channel, _} <- state.irc_to_discord_mapping do
        :ok = Client.join(state.client, channel)
        Logger.debug("Joined #{channel}")
      end
    end

    Logger.debug("resynced")

    :ok
  end
end
