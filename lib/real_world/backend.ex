defmodule RealWorld.Backend do
  use Ecto.Schema
  import Ecto.Changeset

  schema "backends" do
    field(:url, :string)
  end

  @doc false
  def changeset(backend) do
    backend
    |> cast(%{}, [:url])
  end

  def changeset_from_form(backend, attrs) do
    backend
    |> cast(attrs, [:url])
    |> validate_required([:url])
    |> validate_format(:url, ~r/^(http|https):\/\/[^\s]+$/,
      message: "must have the http:// or https:// and no spaces"
    )
  end
end
