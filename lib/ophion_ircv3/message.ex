defmodule Ophion.IRCv3.Message do
  defstruct [:tags, :source, :verb, :params]

  alias Ophion.IRCv3.Message

  # XXX: implement me
  def validate(%Message{} = _msg) do
    :ok
  end

  def validate(_), do: {:error, :invalid_message}
end
