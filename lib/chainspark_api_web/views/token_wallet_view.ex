defmodule ChainsparkApiWeb.TokenWalletView do
  use ChainsparkApiWeb, :view

  def render("token_wallet.json", %{ token_wallet: token_wallet }) do
    %{
      wallet_address: token_wallet.wallet_address,
      value: token_wallet.value
    }
  end
end
