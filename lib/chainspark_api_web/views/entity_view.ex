defmodule ChainsparkApiWeb.EntityView do
  use ChainsparkApiWeb, :view

  alias ChainsparkApiWeb.TokenView
  alias ChainsparkApiWeb.EntityWalletView

  def render("index.json", %{ data: entities }) do
    %{
      jsonapi: %{ version: "1.0"},
      data: render_many(entities, __MODULE__, "entity.json")
    }
  end

  def render("entity.json", %{ entity: entity }) do
    %{
      type: "entity",
      id: entity.id,
      attributes: %{
        name: entity.name,
        btc_balance: entity.btc_balance,
        eth_balance: entity.eth_balance,
        token_value: entity.token_value
      }
    }
  end

  def render("show.json", %{ entity: entity }) do
    %{
      jsonapi: %{ version: "1.0" },
      data: %{
        type: "entity",
        id: entity.id,
        attributes: %{
          name: entity.name,
          token_value: entity.token_value,
          eth_balance: entity.eth_balance,
          eth_value: entity.eth_value,
          btc_balance: entity.btc_balance,
          btc_value: entity.btc_value,
          tokens: render_many(entity.tokens, TokenView, "entity_token.json"),
          eth_wallets: render_many(entity.eth_wallets, EntityWalletView, "entity_wallet.json"),
          btc_wallets: render_many(entity.btc_wallets, EntityWalletView, "entity_wallet.json")
        }
      }  
    }
  end
end
