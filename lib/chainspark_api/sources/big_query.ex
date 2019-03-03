defmodule ChainsparkApi.BigQuery do
  @project_id "chainspark-221302"
  @base_url "https://www.googleapis.com/auth/cloud-platform"

  alias ChainsparkApi.Transactions.Util

  def token_balance(nil), do: []
  def token_balance(""), do: []
  def token_balance(address) do
    case GoogleApi.BigQuery.V2.Api.Jobs.bigquery_jobs_query(
      conn(),
      @project_id,
      [body: %GoogleApi.BigQuery.V2.Model.QueryRequest{ query: token_balance_query(address), useLegacySql: False }]
    ) do
      {:ok, response } ->
        response
        |> process_response
      {:error, _ } -> nil
    end
  end

  def process_response(nil), do: nil
  def process_response(%GoogleApi.BigQuery.V2.Model.QueryResponse{rows: nil}), do: nil
  def process_response(%GoogleApi.BigQuery.V2.Model.QueryResponse{rows: rows}) do
    rows
    |> Enum.map(fn row ->
      {balance, _} =
        Enum.at(row.f, 1).v
        |> Float.parse

      %{
        token_address: Enum.at(row.f, 0).v,
        symbol: Enum.at(row.f, 2).v,
        balance: balance
      }
    end)
  end

  def token_holders(nil), do: []
  def token_holders(""), do: []
  def token_holders(contract_address, limit \\ 100) do
    case GoogleApi.BigQuery.V2.Api.Jobs.bigquery_jobs_query(
      conn(),
      @project_id,
      [body: %GoogleApi.BigQuery.V2.Model.QueryRequest{ query: token_holders_query(contract_address |> String.downcase, limit), useLegacySql: False }]
    ) do
      {:ok, response } ->
        case response.rows do
          nil -> nil
          rows ->
            rows
            |> Enum.map(fn row ->
              {balance, _} = Enum.at(row.f, 1).v
                             |> Float.parse

              {percentage, _} = Enum.at(row.f, 2).v
                                     |> Float.parse

              %{
                address: Enum.at(row.f, 0).v,
                balance: balance |> Util.to_int,
                percentage: percentage
              }
            end)
        end

      {:error, _ } -> nil
    end
  end

  def token_balance_query(address) do
    """
    SELECT token_address, sum(value) AS balance, symbol
    FROM
        (SELECT token_address,
             CAST(value AS float64) / POWER(10, CAST(tokens.decimals as float64)) as value,
             block_timestamp,
             to_address AS address,
             tokens.symbol
        FROM
          `bigquery-public-data.ethereum_blockchain.token_transfers` as token_transfers,
          `bigquery-public-data.ethereum_blockchain.tokens` as tokens
        WHERE token_transfers.token_address = tokens.address and tokens.decimals is not null
        UNION ALL
        SELECT token_address,
             -CAST(value AS float64) / POWER(10, CAST(tokens.decimals as float64)) as value,
             block_timestamp,
             from_address AS address,
             tokens.symbol
        FROM
          `bigquery-public-data.ethereum_blockchain.token_transfers` as token_transfers,
          `bigquery-public-data.ethereum_blockchain.tokens` as tokens
        WHERE token_transfers.token_address = tokens.address and tokens.decimals is not null
        )
    WHERE #{address_sub_query(address)}
    GROUP BY  token_address, symbol
    """
  end

  def address_sub_query(address) when is_binary(address) do
    "address = '#{address |> String.downcase}'"
  end
  def address_sub_query(addresses) do
    addresses = addresses
                |> Enum.reduce("", fn x, acc -> acc <> "'#{x |> String.downcase}', " end)

    addresses = Regex.replace(~r/,\s$/, addresses, "")

    "address in (#{addresses})"
  end


  defp token_holders_query(contract_address, limit) do
    """
    SELECT
      address,
      balance,
      balance / total_supply as percentage_held
    FROM (
      SELECT
        address,
        SUM(value) AS balance,
        CAST(total_supply AS float64) / POWER(10,
          CAST(decimals AS float64)) AS total_supply
      FROM (
        SELECT
          CAST(value AS float64) / POWER(10,
            CAST(tokens.decimals AS float64)) AS value,
          to_address AS address,
          tokens.total_supply,
          tokens.decimals
        FROM
          `bigquery-public-data.ethereum_blockchain.token_transfers` AS token_transfers,
          `bigquery-public-data.ethereum_blockchain.tokens` AS tokens
        WHERE
          token_address = '#{contract_address}'
          AND tokens.address = '#{contract_address}' UNION ALL
        SELECT
          -CAST(value AS float64) / POWER(10,
            CAST(tokens.decimals AS float64)) AS value,
          from_address AS address,
          tokens.total_supply,
          tokens.decimals
        FROM
          `bigquery-public-data.ethereum_blockchain.token_transfers` AS token_transfers,
          `bigquery-public-data.ethereum_blockchain.tokens` AS tokens
        WHERE
          token_address = '#{contract_address}'
          AND tokens.address = '#{contract_address}' )
      GROUP BY
        address,
        total_supply )
    WHERE
      balance > 0
    ORDER BY
      balance DESC
    LIMIT
      #{limit}
    """
  end

  defp conn do
    {:ok, token} = Goth.Token.for_scope(@base_url)
    token.token
    |> GoogleApi.BigQuery.V2.Connection.new
  end
end
