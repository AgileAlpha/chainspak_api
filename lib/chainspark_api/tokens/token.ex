defmodule ChainsparkApi.Tokens.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :contract_address, :binary
    field :symbol, :string
    field :type, TokenType
    field :decimals, :integer
    field :name, :string
    field :price, :integer
    field :volume_24h, :integer
    field :percent_change_24h, :float
    field :percent_change_7d, :float
    field :market_cap, :integer
    field :circulating_supply, :integer
    field :total_supply, :integer
    field :max_supply, :integer

    embeds_many :holders, Holder, on_replace: :delete do
      field :name, :string
      field :address, :binary
      field :balance, :integer
      field :percentage, :float
    end

    timestamps()
  end

  @allowed_fields [:contract_address, :name, :decimals, :type, :symbol, :price, :volume_24h, :percent_change_24h, :percent_change_7d, :market_cap, :circulating_supply, :total_supply, :max_supply]

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, @allowed_fields)
    |> cast_embed(:holders, with: &holder_changeset/2)
    |> validate_required([:name, :type, :symbol])
    |> unique_constraint(:symbol, name: :tokens_symbol_name_index)
  end

  def holder_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:address, :balance, :percentage, :name])
  end
end
