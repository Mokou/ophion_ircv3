defmodule Ophion.IRCv3.Composer.Test do
  use ExUnit.Case

  alias Ophion.IRCv3.Composer
  alias Ophion.IRCv3.Message

  @basicmsg %Message{
    tags: %{},
    source: "kaniini!~kaniini@localhost",
    verb: "JOIN",
    params: ["#chan"]
  }

  @privmsg %Message{
    tags: %{},
    source: "kaniini!~kaniini@localhost",
    verb: "PRIVMSG",
    params: ["#chan", "how are you"]
  }

  describe "sanity -" do
    test "it properly composes a basic rfc1459 message" do
      {:ok, ":kaniini!~kaniini@localhost JOIN #chan\r\n"} =
        @basicmsg
        |> Composer.compose()
    end

    test "it errors when a non-message is passed" do
      {:error, :invalid_message} = Composer.compose(nil)
    end

    test "it errors on a tag-only message" do
      {:error, :invalid_message} =
        %Message{tags: %{"ophion.dev/a" => nil}}
        |> Composer.compose()
    end
  end

  describe "message tags -" do
    test "it properly composes a basic message with tags" do
      {:ok,
       "@account=kaniini;time=2012-06-30T23:59:60.419Z :kaniini!~kaniini@localhost JOIN #chan\r\n"} =
        @basicmsg
        |> Map.put(
          :tags,
          %{
            "account" => "kaniini",
            "time" => "2012-06-30T23:59:60.419Z"
          }
        )
        |> Composer.compose()
    end

    test "it properly escapes semicolons" do
      {:ok,
       "@account=kaniini\\:;time=2012-06-30T23:59:60.419Z :kaniini!~kaniini@localhost JOIN #chan\r\n"} =
        @basicmsg
        |> Map.put(
          :tags,
          %{
            "account" => "kaniini;",
            "time" => "2012-06-30T23:59:60.419Z"
          }
        )
        |> Composer.compose()
    end

    test "it properly escapes spaces" do
      {:ok,
       "@account=kaniini\\sthe\\sbunny;time=2012-06-30T23:59:60.419Z :kaniini!~kaniini@localhost JOIN #chan\r\n"} =
        @basicmsg
        |> Map.put(
          :tags,
          %{
            "account" => "kaniini the bunny",
            "time" => "2012-06-30T23:59:60.419Z"
          }
        )
        |> Composer.compose()
    end

    test "it properly escapes backslashes" do
      {:ok,
       "@account=OPHION\\\\kaniini;time=2012-06-30T23:59:60.419Z :kaniini!~kaniini@localhost JOIN #chan\r\n"} =
        @basicmsg
        |> Map.put(
          :tags,
          %{
            "account" => "OPHION\\kaniini",
            "time" => "2012-06-30T23:59:60.419Z"
          }
        )
        |> Composer.compose()
    end

    test "it properly escapes CR-LF sequences" do
      {:ok,
       "@account=OPHION\\r\\nkaniini;time=2012-06-30T23:59:60.419Z :kaniini!~kaniini@localhost JOIN #chan\r\n"} =
        @basicmsg
        |> Map.put(
          :tags,
          %{
            "account" => "OPHION\r\nkaniini",
            "time" => "2012-06-30T23:59:60.419Z"
          }
        )
        |> Composer.compose()
    end

    test "it properly composes keys without values" do
      {:ok,
       "@account=OPHION\\r\\nkaniini;ophion.dev/admin;time=2012-06-30T23:59:60.419Z :kaniini!~kaniini@localhost JOIN #chan\r\n"} =
        @basicmsg
        |> Map.put(
          :tags,
          %{
            "account" => "OPHION\r\nkaniini",
            "time" => "2012-06-30T23:59:60.419Z",
            "ophion.dev/admin" => nil
          }
        )
        |> Composer.compose()
    end
  end

  describe "source -" do
    test "it properly composes messages without a source" do
      {:ok, "JOIN #chan\r\n"} =
        @basicmsg
        |> Map.put(:source, nil)
        |> Composer.compose()
    end
  end

  describe "params -" do
    test "it properly composes messages with a trailing multi-word param" do
      {:ok, ":kaniini!~kaniini@localhost PRIVMSG #chan :how are you\r\n"} =
        @privmsg
        |> Composer.compose()
    end

    test "it properly composes messages without params" do
      {:ok, ":kaniini!~kaniini@localhost INFO\r\n"} =
        @basicmsg
        |> Map.put(:verb, "INFO")
        |> Map.put(:params, [])
        |> Composer.compose()
    end
  end
end
