defmodule ChainsparkApi.Entities.Entity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entities" do
    field :name, :string
    field :btc_balance, :integer
    field :eth_balance, :integer
    field :token_value, :integer
    field :btc_value, :integer
    field :eth_value, :integer

    embeds_many :tokens, Token, on_replace: :delete do
      field :contract_address, :binary
      field :name, :string
      field :balance, :integer
      field :symbol, :string
      field :total_supply, :integer
      field :perc_held, :float
      field :value, :integer
    end

    embeds_many :btc_wallets, BtcWallet, on_replace: :delete do
      field :wallet_address, :binary
      field :balance, :integer
      field :value, :integer
    end

    embeds_many :eth_wallets, EthWallet, on_replace: :delete do
      field :wallet_address, :binary
      field :balance, :integer
      field :value, :integer
    end

    timestamps()
  end

  def changeset(entity, attrs) do
    entity
    |> cast(attrs, [:name, :btc_balance, :eth_balance, :token_value, :eth_value, :btc_value])
    |> cast_embed(:tokens, with: &token_changeset/2)
    |> cast_embed(:btc_wallets, with: &wallet_changeset/2)
    |> cast_embed(:eth_wallets, with: &wallet_changeset/2)
    |> unique_constraint(:name)
  end

  def token_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:contract_address, :name, :balance, :symbol, :total_supply, :perc_held, :value])
  end

  def wallet_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:wallet_address, :balance, :value])
  end
end
