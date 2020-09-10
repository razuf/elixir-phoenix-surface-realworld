defmodule RealWorld.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field(:body, :string)
    field(:article_slug, :string)

    timestamps(inserted_at: :createdAt, updated_at: :updatedAt)
  end

  @doc false
  def changeset(comment) do
    comment
    |> cast(%{}, [:body])
  end

  def changeset_from_form(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
