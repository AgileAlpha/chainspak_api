defmodule ChainsparkApiWeb.Socket do
  use Phoenix.Socket

  channel "transactions", ChainsparkApiWeb.TransactionChannel

  def connect(_params, socket) do
    {:ok, socket}
  end 

  def id(_socket), do: nil
end
