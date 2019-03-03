defmodule ChainsparkApiWeb.WalletView do
  use ChainsparkApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :name,
    :address,
    :type,
    :tokens,
    :balance,
    :transactions,
    :activity,
    :details
  ]
end
