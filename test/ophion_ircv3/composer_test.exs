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

  describe "sanity -" do
    test "it properly composes a basic rfc1459 message" do
      {:ok, ":kaniini!~kaniini@localhost JOIN #chan\r\n"} =
        @basicmsg
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
end
