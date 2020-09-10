defmodule RealWorld.Helpers do
  import Ecto.Changeset

  @moduledoc """
  Some of my helper functions.
  stringify_keys - adpted version of kipcole9/Map.Helpers - Thanks!
  """

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
  Receives a validation tuple from a changeset and flatten the error message
  """
  def flatten_error_message({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  @doc """
  Small helper for get_field of a changeset
  usefull in a form to return an empty string instead of nil
  """
  def get_field(%Ecto.Changeset{} = changeset, key) do
    Ecto.Changeset.get_field(changeset, key)
  end

  def get_field(nil, _key) do
    ""
  end

  @doc """
  Date format helper - us date
  """
  def format_datetime(nil) do
    ""
  end

  def format_datetime(%{day: day, month: month, year: year}) do
    "#{format_month(month)} #{day}, #{year}"
  end

  def format_datetime(datetime) do
    %{day: day, month: month, year: year} = NaiveDateTime.from_iso8601!(datetime)
    "#{format_month(month)} #{day}, #{year}"
  end

  defp format_month(1), do: "January"
  defp format_month(2), do: "February"
  defp format_month(3), do: "March"
  defp format_month(4), do: "April"
  defp format_month(5), do: "May"
  defp format_month(6), do: "June"
  defp format_month(7), do: "July"
  defp format_month(8), do: "August"
  defp format_month(9), do: "September"
  defp format_month(10), do: "October"
  defp format_month(11), do: "November"
  defp format_month(12), do: "December"

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
