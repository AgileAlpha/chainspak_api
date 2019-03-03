defmodule ChainsparkApi.Accounts do
  import Ecto.Query, warn: false

  alias ChainsparkApi.Repo
  alias ChainsparkApi.Accounts.User

  def create(params) do
    User.changeset(%User{}, params)
    |> Repo.insert()
  end

  def get_user_by_email_and_password(nil, _password), do: {:error, :invalid}
  def get_user_by_email_and_password(_email, nil), do: {:error, :invalid}

  def get_user_by_email_and_password(email, password) do
    with  %User{} = user <- Repo.get_by(User, email: email),
          true <- Comeonin.Bcrypt.checkpw(password, user.password_hash) do
      {:ok, user}
    else
      _ ->
        Comeonin.Bcrypt.dummy_checkpw
        {:error, :unauthorized}
    end
  end
end
