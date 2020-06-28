defmodule Ophion.IRCv3.Parser do
  require Logger

  alias Ophion.IRCv3.Message

  defp unescape_value(value) when is_binary(value) do
    value
    |> String.replace("\\s", " ")
    |> String.replace("\\r", "\r")
    |> String.replace("\\n", "\n")
    |> String.replace("\\:", ";")
    |> String.replace("\\\\", "\\")
  end

  defp unescape_value(_), do: nil

  defp parse(%Message{} = msg, "@" <> data) do
    with [tags, rest] <- String.split(data, " ", parts: 2),
         tags <- String.split(tags, ";") do
      tags =
        tags
        |> Enum.map(fn tag ->
          cond do
            String.contains?(tag, "=") ->
              [key, value] = String.split(tag, "=", parts: 2)
              {key, unescape_value(value)}

            true ->
              {tag, nil}
          end
        end)
        |> Enum.into(%{})

      msg = Map.put(msg, :tags, tags)

      parse(msg, rest)
    else
      err -> err
    end
  end

  defp parse(%Message{source: nil} = msg, ":" <> data) do
    with [source, rest] <- String.split(data, " ", parts: 2) do
      msg = Map.put(msg, :source, source)

      parse(msg, rest)
    else
      err -> err
    end
  end

  defp parse(%Message{verb: nil} = msg, data) do
    with [verb, rest] <- String.split(data, " ", parts: 2) do
      msg = Map.put(msg, :verb, verb)

      parse(msg, rest)
    else
      [verb] ->
        msg = Map.put(msg, :verb, verb)

        {:ok, msg}

      err ->
        err
    end
  end

  defp parse(%Message{verb: v} = msg, data) when is_binary(v) do
    pieces =
      if String.contains?(data, ":") do
        [head, tail] = String.split(data, ":", parts: 2)

        (head |> String.replace_trailing(" ", "") |> String.split(" ")) ++ [tail]
      else
        String.split(data, " ")
      end

    msg = Map.put(msg, :params, pieces)

    {:ok, msg}
  end

  defp parse(%Message{} = _msg, _), do: {:error, :invalid_message}

  def parse(msg) when is_binary(msg) do
    with {:ok, result} <- parse(%Message{}, msg) do
      {:ok, result}
    else
      err -> err
    end
  end

  def parse(_), do: {:error, :invalid_message}
end
