defmodule DiscordIrcEx.IrcColor do
  def colorize(string) do
    "\x03#{:erlang.phash2(string, 12) + 2}#{string}\x0f"
  end
end
