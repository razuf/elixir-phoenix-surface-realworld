defmodule RealWorld.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field(:body, :string)
    field(:description, :string)
    field(:slug, :string)
    field(:tagList, {:array, :string})
    field(:tag_list_string, :string)
    field(:title, :string)
    field(:favorited, :boolean)
    field(:favoritesCount, :integer)

    timestamps(inserted_at: :createdAt, updated_at: :updatedAt)
  end

  @doc false
  def changeset(article) do
    article
    |> cast(%{}, [:body, :description, :title, :tag_list_string])
  end

  def changeset_from_article(article, article_attrs) do
    article
    |> cast(article_attrs, [:body, :description, :title, :slug, :tagList, :tag_list_string])
    |> validate_required([:body, :description, :title])
    |> update_tag_list_string()
  end

  def changeset_from_form(article, form_params) do
    article
    |> cast(form_params, [:body, :description, :title, :tagList, :tag_list_string])
    |> validate_required([:body, :description, :title])
    |> update_tagList()
  end

  defp update_tagList(changeset) do
    case get_field(changeset, :tag_list_string) do
      list_string when is_binary(list_string) ->
        put_change(changeset, :tagList, String.split(list_string))

      _ ->
        changeset
    end
  end

  defp update_tag_list_string(changeset) do
    case get_field(changeset, :tagList) do
      list when is_list(list) ->
        put_change(changeset, :tag_list_string, Enum.join(list, " "))

      _ ->
        changeset
    end
  end
end
