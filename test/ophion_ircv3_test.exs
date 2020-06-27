defmodule Ophion.IRCv3.Test do
  use ExUnit.Case

  alias Ophion.IRCv3.Message

  describe "Ophion.IRCv3.compose/1 -" do
    test "it composes messages" do
      message = %Message{
        tags: %{},
        source: "kaniini!~kaniini@localhost",
        verb: "JOIN",
        params: ["#chan"]
      }

      {:ok, ":kaniini!~kaniini@localhost JOIN #chan\r\n"} = Ophion.IRCv3.compose(message)
    end
  end

  describe "Ophion.IRCv3.parse/1 -" do
  end
end
