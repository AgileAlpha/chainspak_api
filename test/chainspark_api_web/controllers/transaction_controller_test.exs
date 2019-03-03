defmodule ChainsparkApiWeb.TransactionControllerTest do
  use ChainsparkApiWeb.ConnCase
  import ChainsparkApi.Factory
  import ChainsparkApi.Guardian

  setup do
    user = insert(:user)

    {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

    conn = build_conn()
           |> put_req_header("content-type", "application/vnd.api+json")
           |> put_req_header("chainspark-secret", "123")
           |> put_req_header("authorization", "bearer #{token}")

    insert(:btc_transaction)
    insert(:eth_transaction)

    %{ user: user, conn: conn }
  end

  describe "GET /api/transactions" do
    test "returns transactions when authorized", %{ conn: conn } do
      conn = get conn, "/api/transactions"
      response = json_response(conn, 200)["data"]

      assert Kernel.length(response) == 2
    end

    test "returns transactions with eth filter", %{ conn: conn } do
      conn = get conn, "/api/transactions?page[number]=1&page[size]=50&filter[type]=eth"
      response = json_response(conn, 200)["data"]
                 |> List.first

      assert response["attributes"]["symbol"] == "ETH"
    end

    test "returns transactions with btc filter", %{ conn: conn } do
      conn = get conn, "/api/transactions?page[number]=1&page[size]=50&filter[type]=btc"
      response = json_response(conn, 200)["data"]
                 |> List.first

      assert response["attributes"]["symbol"] == "BTC"
    end

    test "returns transactions with threshold filter", %{ conn: conn } do
      insert(:eth_transaction, cents_value: 500_000_00, hash: "123")
      insert(:btc_transaction, cents_value: 250_000_00, hash: "234")

      conn = get conn, "/api/transactions?page[number]=1&page[size]=50&filter[threshold]=50000000"
      response = json_response(conn, 200)["data"]

      assert Kernel.length(response) == 1
      assert List.first(response)["attributes"]["symbol"] == "ETH"
    end

    test "returns transactions with threshold filter multiple", %{ conn: conn } do
      insert(:eth_transaction, cents_value: 500_000_00, hash: "123")
      insert(:btc_transaction, cents_value: 750_000_00, hash: "234")

      conn = get conn, "/api/transactions?page[number]=1&page[size]=50&filter[threshold]=50000000"
      response = json_response(conn, 200)["data"]

      assert Kernel.length(response) == 2
    end

    test "returns transactions with time filter", %{ conn: conn } do
      insert(:eth_transaction, cents_value: 500_000_00, hash: "123", timestamp: :os.system_time(:second) - 3600 * 48)
      insert(:eth_transaction, cents_value: 500_000_00, hash: "124")

      conn = get conn, "/api/transactions?page[number]=1&page[size]=50&filter[time]=1d"
      response = json_response(conn, 200)["data"]

      assert Kernel.length(response) == 3 # there's another 2 txs in setup
    end

    test "returns eth transactions with wallet filter", %{ conn: conn } do
      insert(:wallet, name: "kraken", address: "0x123")
      insert(:btc_transaction, cents_value: 500_000_00, hash: "1213", from: "0x123")
      insert(:eth_transaction, cents_value: 500_000_00, hash: "123", from: "0x123")
      insert(:eth_transaction, cents_value: 500_000_00, hash: "125", symbol: "BAT", from: "0x124", to: "0x123")
      insert(:eth_transaction, cents_value: 500_000_00, hash: "126", from: "0x124", to: "0x125")

      conn = get conn, "/api/transactions?page[number]=1&page[size]=50&filter[type]=eth&filter[wallet]=0x123"
      response = json_response(conn, 200)["data"]

      assert Kernel.length(response) == 2
    end

    test "returns btc transactions with wallet filter", %{ conn: conn } do
      insert(:wallet, name: "kraken", address: "0x123")
      insert(:btc_transaction, cents_value: 500_000_00, hash: "1213", from: "0x123")
      insert(:eth_transaction, cents_value: 500_000_00, hash: "123", from: "0x123")
      insert(:eth_transaction, cents_value: 500_000_00, hash: "126", from: "0x124", to: "0x125")

      conn = get conn, "/api/transactions?page[number]=1&page[size]=50&filter[type]=btc&filter[wallet]=0x123"
      response = json_response(conn, 200)["data"]

      assert Kernel.length(response) == 1
    end

    test "returns transactions with exchange filter", %{ conn: conn } do
      insert(:wallet, name: "Coinbase", address: "0x123")
      insert(:wallet, name: "Bitrex", address: "0x124")

      insert(:btc_transaction, cents_value: 500_000_00, hash: "121", from: "0x123", from_name: "Coinbase")
      insert(:eth_transaction, cents_value: 500_000_00, hash: "123", from: "0x123", from_name: "Coinbase")
      insert(:eth_transaction, cents_value: 500_000_00, hash: "125", symbol: "BAT", from: "0x124", to: "0x123", to_name: "Coinbase")
      insert(:eth_transaction, cents_value: 500_000_00, hash: "126", symbol: "CMCT", from_name: "Bitrex", from: "0x124", to: "0x125")

      conn = get conn, "/api/transactions?page[number]=1&page[size]=50&filter[exchange]=Coinbase"
      response = json_response(conn, 200)["data"]

      assert Kernel.length(response) == 3
    end

    test "returns eth transactions in ascending order", %{ conn: conn } do
      insert(:wallet, name: "Coinbase", address: "0x123")
      insert(:wallet, name: "Bitrex", address: "0x124")

      insert(:eth_transaction, cents_value: 500_000_03, hash: "125", from: "0x124", to: "0x123", to_name: "Coinbase")
      insert(:eth_transaction, cents_value: 500_000_01, hash: "121", from: "0x123", from_name: "Coinbase")
      insert(:eth_transaction, cents_value: 500_000_04, hash: "126", from_name: "Bitrex", from: "0x124", to: "0x125")
      insert(:eth_transaction, cents_value: 500_000_02, hash: "123", from: "0x123", from_name: "Coinbase")

      conn = get conn, "/api/transactions?page[number]=1&page[size]=50&filter[type]=eth&order[value]=asc"
      response = json_response(conn, 200)["data"]

      first = response |> Enum.at(0)
      last  = response |> Enum.at(-1)

      assert length(response) == 5
      assert first["attributes"]["cents-value"] == 50_000_00 # from the factory
      assert last["attributes"]["cents-value"]  == 500_000_04
    end

    test "returns transactions in descending order", %{ conn: conn } do
      insert(:wallet, name: "Coinbase", address: "0x123")
      insert(:wallet, name: "Bitrex", address: "0x124")

      insert(:eth_transaction, cents_value: 500_000_03, hash: "125", from: "0x124", to: "0x123", to_name: "Coinbase")
      insert(:eth_transaction, cents_value: 500_000_01, hash: "121", from: "0x123", from_name: "Coinbase")
      insert(:eth_transaction, cents_value: 500_000_04, hash: "126", from_name: "Bitrex", from: "0x124", to: "0x125")
      insert(:eth_transaction, cents_value: 500_000_02, hash: "123", from: "0x123", from_name: "Coinbase")

      conn = get conn, "/api/transactions?page[number]=1&page[size]=50&filter[type]=eth&order[value]=desc"
      response = json_response(conn, 200)["data"]

      first = response |> Enum.at(0)
      last  = response |> Enum.at(-1)

      assert length(response) == 5
      assert first["attributes"]["cents-value"] == 500_000_04
      assert last["attributes"]["cents-value"]  == 50_000_00 # from the factory
    end

    test "returns 401 when not authorized" do
      conn = build_conn()
             |> put_req_header("content-type", "application/vnd.api+json")

      conn = get conn, "/api/transactions?page[number]=1&page[size]=50&filter[type]=eth"

      assert conn.status == 401
    end
  end
end
