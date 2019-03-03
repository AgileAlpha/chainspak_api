defmodule ChainsparkApi.TransactionsTest do
  use ChainsparkApi.DataCase

  alias ChainsparkApi.Transactions
  import ChainsparkApi.Factory

  setup do
    btc_attrs = %{
      "from" => "3EV89EKcKYefNyDAFw4p8djwU2Z4LNbSWK",
      "to" => "1FarncUbSa6ew1hcQmXETLnc7n5a8X4KXn",
      "value" => "1850000",
      "token_amount" => 185,
      "is_btc_tx" => true,
      "symbol" => "BTC",
      "hash" => "65347c379ede7a4e07124fab4133b4245b93567700368ca08d631eacb36048e4",
      "timestamp" => 1540330618
    }

    eth_attrs = %{
      "from" => "0xd6487eb436f2b3a8c04e08a75ed29a40c617f725",
      "to" => "0x9a59d256812c1ca3b76ab44a08529c7acae2f428",
      "value" => "0x6124fee993bc0000",
      "token_amount" => 7000000000000000000,
      "is_token_tx" =>  false,
      "hash" => "0x6e729e6b73c3f0c8a24d0db6380f15963dbccfbfdf6837b717cac0a373c469c0",
      "timestamp" => 1540330618
    }

    erc20_attrs = %{
      "from" => "0xd6487eb436f2b3a8c04e08a75ed29a40c617f725",
      "to" => "0x9a59d256812c1ca3b76ab44a08529c7acae2f428",
      "value" => "0x6124fee993bc0000",
      "token_amount" => "348129084399989900000",
      "is_token_tx" =>  true,
      "hash" => "0x6e729e6b73c3f0c8a24d0db6380f15963dbccfbfdf6837b717cac0a373c469c0",
      "timestamp" => 1540330618,
      "transfer_log" => %{
        "address" => "0xf230b790e05390fc8295f4d3f60332c93bed42e2",
        "blockHash" => "0x1ff9d55bca8aa3fcb4da986e50794d10a47f6a4414a147c814806dbf3b54c21f",
        "blockNumber" => "0x644322",
        "data" => "0x000000000000000000000000000000000000000000000000000000003595a6c0",
        "logIndex" => "0xc",
        "removed" => false,
        "topics" => ["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
         "0x000000000000000000000000775e5b53acf10c29ba76b4c64ac22e9b93a6183e",
         "0x0000000000000000000000003f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be"],
        "transactionHash" => "0x6939d833e0550e9e72e24bd7aa15e6ac66eba66ba6107eeae5c293fc2f5bb6a4",
        "transactionIndex" => "0x28"
        }
      }

    eth_split_attrs = %{
      "from" => "0xd67f76d78fa3597b019f138f9c6481711d63fd6b",
      "to" => "0x267be1c1d684f78cb4f6a176c4911b741e4ffdc0",
      "value" => "0x00000000000000000000000000000000000000000000054b40b0d8e4ec546500",
      "token_amount" => "24999999683968500000000",
      "is_token_tx" =>  true,
      "hash" => "0x6b39e7d979f74e16718f5cba3d488720f27c34047c55b6a9ebb4dffa3e6aa714",
      "timestamp" => 1540330618,
      "transfer_log" => %{
        "address" => "0xfa52274dd61e1643d2205169732f29114bc240b3",
        "blockHash" => "0x1ff9d55bca8aa3fcb4da986e50794d10a47f6a4414a147c814806dbf3b54c21f",
        "blockNumber" => "0x644322",
        "data" => "0x000000000000000000000000000000000000000000000000000000003595a6c0",
        "logIndex" => "0xc",
        "removed" => false,
        "topics" => ["0x56b138798bd325f6cc79f626c4644aa2fd6703ecb0ab0fb168f883caed75bf32",
         "0x0000000000000000000000003a03fabbfb7c2377d7216c22ed8f162bd7bef5a4",
         "0x000000000000000000000000267be1c1d684f78cb4f6a176c4911b741e4ffdc0"],
        "transactionHash" => "0x6b39e7d979f74e16718f5cba3d488720f27c34047c55b6a9ebb4dffa3e6aa714",
        "transactionIndex" => "0x28"
        }
      }

    btc = insert(:token, name: "Bitcoin", symbol: "BTC", price: 600000, decimals: 8, type: "btc")

    %{ btc_attrs: btc_attrs, eth_attrs: eth_attrs, erc20_attrs: erc20_attrs, eth_split_attrs: eth_split_attrs, btc: btc }
  end

  describe "create_btc_transactions/1" do
    test "it creates a btc transaction with valid attrs", %{ btc_attrs: attrs, btc: btc } do
      insert(:wallet, name: "Binance", address: "3EV89EKcKYefNyDAFw4p8djwU2Z4LNbSWK")

      {:ok, transaction} = Transactions.create_btc_transaction(attrs)

      assert transaction.from_name == "Binance"
      assert transaction.to_name == "Unknown wallet"
      assert transaction.symbol == "BTC"
      assert transaction.cents_value == btc.price * attrs["token_amount"]
    end

    test "it creates a btc transaction with valid attrs with unknown wallets", %{ btc_attrs: attrs, btc: btc } do
      {:ok, transaction} = Transactions.create_btc_transaction(attrs)

      assert transaction.from_name == "Unknown wallet"
      assert transaction.to_name == "Unknown wallet"
      assert transaction.symbol == "BTC"
      assert transaction.cents_value == btc.price * attrs["token_amount"]
    end
  end

  describe "create_eth_transactions/1" do
    test "it creates an eth transaction with valid attrs", %{ eth_attrs: attrs } do
      insert(:wallet, name: "Kraken", address: "0x9a59d256812c1ca3b76ab44a08529c7acae2f428")
      insert(:token, name: "Ethereum", symbol: "ETH", price: 20000000, decimals: 18, type: "eth")

      {:ok, transaction} = Transactions.create_eth_transaction(attrs)

      assert transaction.from_name == "Unknown wallet"
      assert transaction.symbol == "ETH"
      assert transaction.to_name == "Kraken"
      assert transaction.cents_value == 140000000
      assert transaction.token_amount == 7
    end
  end

  describe "create_erc20_transactions/1" do
    test "it ignores an erc20 transaction if token is not found", %{ erc20_attrs: attrs } do
      insert(:wallet, name: "Kraken", address: "0x9a59d256812c1ca3b76ab44a08529c7acae2f428")

      {:error, :tx_rejected} = Transactions.create_erc20_transaction(attrs)
    end

    test "it creates an erc20 transaction with valid attrs", %{ erc20_attrs: attrs } do
      insert(:wallet, name: "Kraken", address: "0x9a59d256812c1ca3b76ab44a08529c7acae2f428")
      insert(:token, name: "CrappyCoin", contract_address: "0x9a59d256812c1ca3b76ab44a08529c7acae2f428", price: 450000, decimals: 18, symbol: "CC")

      {:ok, transaction} = Transactions.create_erc20_transaction(attrs)

      assert transaction.from_name == "Unknown wallet"
      assert transaction.to_name == "Kraken"
      assert transaction.cents_value == 156600000
      assert transaction.token_amount == 348
    end

    test "it creates an eth split transaction with valid attrs", %{eth_split_attrs: attrs } do
      insert(:token, name: "Ethereum", symbol: "ETH", price: 10000, decimals: 18, type: "eth")

      {:ok, transaction} = Transactions.create_erc20_transaction(attrs)

      assert transaction.from_name == "Unknown wallet"
      assert transaction.to_name == "Unknown wallet"
      assert transaction.cents_value == 2_500_000_00
      assert transaction.token_amount == 25_000
    end

    test "it handles transactions with value 0", %{erc20_attrs: attrs } do
      insert(:wallet, name: "Kraken", address: "0x9a59d256812c1ca3b76ab44a08529c7acae2f428")
      insert(:token, name: "CrappyCoin", contract_address: "0x9a59d256812c1ca3b76ab44a08529c7acae2f428", price: 450000, decimals: 18, symbol: "CC")

      {:ok, transaction } = attrs
                            |> Map.put("value", 0)
                            |> Transactions.create_erc20_transaction

      assert transaction.from_name == "Unknown wallet"
      assert transaction.symbol == "CC"
      assert transaction.to_name == "Kraken"
      assert transaction.cents_value == 156600000
      assert transaction.token_amount == 348
    end

    test "it handles transaction" do
      insert(:token, contract_address: "0xdfdb480afc956c639860b020fc0a3d2438d84a6b", symbol: "CMCT", price: 66666600)

      attrs =  %{"from" => "0x7b45a572ea991887a01fd919c05edf1cac79c311", "timestamp" => 1540501067, "hash" => "0xa2d69503c86b02bbffd547b0b400dfe64e940038289df4d7461cf927e8ba28c0", "is_token_tx" => true, "to" => "0xdfdb480afc956c639860b020fc0a3d2438d84a6b", "token_amount" => "23633253012248385458", "transfer_log" => %{"address" => "0x3597bfd533a99c9aa083587b074434e61eb0a258", "blockHash" => "0x857043b065344484f4e21acb2dfbb72f7145a3e80f26477b05de3090be9de2e0", "blockNumber" => "0x6472b4", "data" => "0x0000000000000000000000000000000000000000000000000000d6f17481bef3", "logIndex" => "0x19", "removed" => false, "topics" => ["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", "0x0000000000000000000000007b45a572ea991887a01fd919c05edf1cac79c311", "0x000000000000000000000000dfdb480afc956c639860b020fc0a3d2438d84a6b"], "transactionHash" => "0xa2d69503c86b02bbffd547b0b400dfe64e940038289df4d7461cf927e8ba28c0", "transactionIndex" => "0x78"}, "value" => "0x0000000000000000000000000000000000000000000000000000d6f17481bef3"}

      {:ok, transaction } = attrs
                             |> Transactions.create_erc20_transaction

      assert transaction.symbol == "CMCT"
    end

    test "it handles failed tx" do
      attrs = %{"from" => 0, "hash" => "0xd8353eb819f99ddf1d9b8514d40bcef1e25052fd0b33bc20de5097515afc36a0", "is_token_tx" => true, "timestamp" => 1540501209, "to" => 0, "token_amount" => "0", "transfer_log" => %{"address" => "0x06012c8cf97bead5deae237070f9587f8e7a266d", "blockHash" => "0x103637a7daded9c737dc3747be36649ba8d139c16e202a7297ecb4fd462af04d", "blockNumber" => "0x64730e", "data" => "0x000000000000000000000000c7af99fe5513eb6710e6d5f44f9989da40f27f2600000000000000000000000050d7826d4a75fc8dcf35146fc909268cccd65d9d0000000000000000000000000000000000000000000000000000000000108637", "logIndex" => "0xb6", "removed" => false,  "topics" => ["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"], "transactionHash" => "0xd8353eb819f99ddf1d9b8514d40bcef1e25052fd0b33bc20de5097515afc36a0", "transactionIndex" => "0x38"}, "value" => 0}

      {:error, :tx_rejected } = attrs
                                |> Transactions.create_erc20_transaction
    end
  end
end
