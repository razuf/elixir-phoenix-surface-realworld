defmodule RealWorld.Helpers do
  @moduledoc """
  Some of my helper functions.
  stringify_keys - adpted version of kipcole9/Map.Helpers - Thanks!
  """
  import Ecto.Changeset

  @doc """
  Receives a changeset and multiple errors from key list added
  """
  def add_errors_to_changeset(changeset, errors) do
    Enum.reduce(
      Map.keys(errors),
      changeset,
      fn key, changeset ->
        err_list = Map.get(errors, key)

        changeset
        |> add_error(key, Enum.join(err_list, " and "))
      end
    )
  end

  @doc """
  Convert map atom keys to strings
  """
  def stringify_keys(nil) do
    nil
  end

  def stringify_keys(schema = %_{__meta__: _}) do
    map =
      schema
      |> Map.from_struct()
      |> Map.delete(:__meta__)

    stringify_keys(map)
  end

  def stringify_keys(struct = %NaiveDateTime{}) do
    struct
  end

  def stringify_keys(struct = %_{}) do
    map =
      struct
      |> Map.from_struct()

    stringify_keys(map)
  end

  def stringify_keys(map = %{}) do
    map
    |> Enum.map(fn
      {k, v} when is_atom(k) ->
        {Atom.to_string(k), stringify_keys(v)}

      {k, v} when is_binary(k) ->
        {k, stringify_keys(v)}
    end)
    |> Enum.into(%{})
  end

  def stringify_keys([head | rest]) do
    [stringify_keys(head) | stringify_keys(rest)]
  end

  def stringify_keys(not_a_map) do
    not_a_map
  end
end
