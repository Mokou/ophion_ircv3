defmodule Ophion.IRCv3.Message do
  defstruct [:tags, :source, :verb, :params]

  alias Ophion.IRCv3.Message

  # verb is required to be set
  def validate(%Message{verb: nil}), do: {:error, :invalid_message}
  def validate(%Message{}), do: :ok
  def validate(_), do: {:error, :invalid_message}
end
