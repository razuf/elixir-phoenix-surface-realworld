defmodule RealWorld.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:session_id, :string, autogenerate: false}

  schema "users" do
    field(:bio, :string)
    field(:email, :string)
    field(:image, :string)
    field(:password, :string)
    field(:token, :string)
    field(:username, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :bio, :image, :password, :token, :session_id])
    |> validate_required([:email, :username, :password])
    |> validate_length(:username, min: 1, max: 20)
    |> validate_length(:password, min: 8, max: 72)
    |> validate_email(:email)
  end

  def changeset_login(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
  end

  def changeset_auth(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :token, :session_id])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 8, max: 72)
    |> validate_email(:email)
  end

  defp validate_email(changeset, :email) do
    changeset
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end
end
