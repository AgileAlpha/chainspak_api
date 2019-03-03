defmodule ChainsparkApiWeb.TransactionView do
  use ChainsparkApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :hash, 
    :from, 
    :from_name, 
    :to, 
    :to_name, 
    :contract_address, 
    :value, 
    :cents_value,
    :token_amount,
    :timestamp,
    :symbol
  ]
end
