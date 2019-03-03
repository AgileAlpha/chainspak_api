defmodule ChainsparkApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChainsparkApi.Accounts.User

  schema "users" do
    field :password_hash, :string
    field :email, :string

    field :password, :string, virtual: true

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> validate_length(:password, min: 8)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end
end

