defmodule ChainsparkApi.TokensTest do
  use ChainsparkApi.DataCase

  alias ChainsparkApi.Tokens

  describe "create_token/1" do
    test "updates a token if it already exists" do
      Tokens.create_token(%{ name: "Some token", symbol: "SMT", type: :erc20, decimals: 18})
      Tokens.create_token(%{ name: "Some token", symbol: "SMT", type: :erc20, decimals: 20})

      {:ok, token } = Tokens.get_by_symbol("SMT")

      assert token.decimals == 20
    end
  end
end
