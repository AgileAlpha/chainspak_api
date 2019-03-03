defmodule ChainsparkApi.Guardian do
  use Guardian, otp_app: :chainspark_api

  alias ChainsparkApi.Repo
  alias ChainsparkApi.Accounts.User

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{ "sub" => id}) do
    case Repo.get(User, id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user }
    end
  end
end
