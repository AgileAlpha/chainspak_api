defmodule ChainsparkApi.BlockscoutTest do
  use ChainsparkApi.DataCase

  alias ChainsparkApi.Blockscout

  describe "Blockscout" do
    test "sum_up_tokens/1 correctly sums up token balances" do
      processed =
        [
          %{"name" => "ZRX", "balance" => "0" },
          %{"name" => "ZRX", "balance" => "" },
          %{"name" => "ZRX", "balance" => nil },
          %{"name" => "ZRX", "balance" => "10" },
          %{"name" => "DAI", "balance" => "10" },
          %{"name" => "ZRX", "balance" => "11" }
        ]
        |> Blockscout.sum_up_tokens

      assert processed["ZRX"]["balance"] == 21
      assert processed["DAI"]["balance"] == 10
    end

    test "days_ago_unix/1 correctly gives days ago in unix" do
      {:ok, result_date} =
        Blockscout.days_ago_unix(5)
        |> DateTime.from_unix

      assert Date.diff(Date.utc_today, result_date) == 5
    end

    test "mark_activity_level/1 correctly marks activity level" do
      shortTxList = Enum.to_list(1..2)
      medTxList   = Enum.to_list(1..45)
      longTxList  = Enum.to_list(1..100)

      assert Blockscout.mark_activity_level(shortTxList) == "LOW"
      assert Blockscout.mark_activity_level(medTxList)   == "MED"
      assert Blockscout.mark_activity_level(longTxList)  == "HIGH"
    end
  end
end
