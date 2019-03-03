defmodule ChainsparkApiWeb.TokenView do
  use ChainsparkApiWeb, :view

  alias ChainsparkApiWeb.HolderView

  def render("index.json", %{ data: tokens }) do
    %{ 
      jsonapi: %{ version: "1.0"},
      data: render_many(tokens, __MODULE__, "token.json")
    }
  end

  def render("token.json", %{ token: token }) do
    %{
      type: "erc20",
      id: token.id,
      attributes: %{
        name: token.name,
        symbol: token.symbol,
        type: token.type
      }
    }
  end

  def render("entity_token.json", %{ token: token }) do
    %{
      symbol: token.symbol,
      value: token.value,
      total_supply: token.total_supply,
      name: token.name,
      id: token.id,
      contract_address: token.contract_address,
      balance: token.balance,
      perc_held: token.perc_held
    }
  end

  def render("show.json", %{ data: token }) do
    %{
      jsonapi: %{ version: "1.0"},
      data: %{
        type: "erc20",
        id: token.id,
        attributes: %{
          symbol: token.symbol,
          contract_address: token.contract_address,
          name: token.name,
          price: token.price,
          type: token.type,
          volume_24h: token.volume_24h,
          percent_change_24h: token.percent_change_24h,
          percent_change_7d: token.percent_change_7d,
          market_cap: token.market_cap,
          circulating_supply: token.circulating_supply,
          total_supply: token.total_supply,
          max_supply: token.max_supply,
          holders: render_many(token.holders, HolderView, "holder.json")
        }
      }
    }
  end
end
