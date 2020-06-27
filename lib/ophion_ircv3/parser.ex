defmodule Ophion.IRCv3.Parser do
  def parse(msg) when is_binary(msg), do: {:error, :unimplemented}
  def parse(_), do: {:error, :invalid_message}
end
