defmodule ChainsparkApiWeb.TransactionChannel do
  use ChainsparkApiWeb, :channel

  def join("transactions", params, socket) do
    Process.flag(:trap_exit, true)

    {:ok, assign(socket, :subscription_id, params["jwt"])}
  end

  def send_tx(event, msg) do
    ChainsparkApiWeb.Endpoint.broadcast_from! self(), "transactions", event, msg
  end
end
