defmodule ChainsparkApiWeb.HolderView do
  use ChainsparkApiWeb, :view

  def render("holder.json", %{ holder: holder }) do
    %{
      address: holder.address,
      name: holder.name,
      balance: holder.balance,
      percentage: holder.percentage
    }
  end
end
