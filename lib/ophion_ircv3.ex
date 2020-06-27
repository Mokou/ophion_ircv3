defmodule Ophion.IRCv3 do
  @moduledoc """
  Documentation for `Ophion.IRCv3`.
  """

  alias Ophion.IRCv3.Composer
  alias Ophion.IRCv3.Message
  alias Ophion.IRCv3.Parser

  @doc """
  Parse an IRCv3 frame into an `%Ophion.IRCv3.Message{}`.
  """
  def parse(msg) do
    with {:ok, %Message{} = data} <- Parser.parse(msg) do
      {:ok, data}
    else
      {:error, e} ->
        {:error, e}

      e ->
        {:error, {:unknown_error, e}}
    end
  end

  @doc """
  Compose an IRCv3 frame from an `%Ophion.IRCv3.Message{}`.
  """
  def compose(%Message{} = msg) do
    with {:ok, data} <- Composer.compose(msg) do
      {:ok, data}
    else
      {:error, e} ->
        {:error, e}

      e ->
        {:error, {:unknown_error, e}}
    end
  end
end
