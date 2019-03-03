defmodule ChainsparkApiWeb.EntityWalletView do
  use ChainsparkApiWeb, :view

  def render("entity_wallet.json", %{ entity_wallet: eth_wallet }) do
    %{
      wallet_address: eth_wallet.wallet_address,
      value: eth_wallet.value,
      balance: eth_wallet.balance
    }
  end
end
