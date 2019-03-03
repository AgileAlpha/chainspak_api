defmodule ChainsparkApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    children = [
      ChainsparkApi.Repo,
      ChainsparkApiWeb.Endpoint,
    ]

    jobs = [
      {ChainsparkApi.Jobs.TokenPrices, ChainsparkApi.TokenPricesSupervisor},
      {ChainsparkApi.Jobs.Entities, ChainsparkApi.EntitiesSupervisor},
      {ChainsparkApi.Jobs.TokenHolders, ChainsparkApi.TokenHoldersSupervisor}
    ]

    # Start jobs
    jobs |> Enum.each(&start_job/1)

    opts = [strategy: :one_for_one, name: ChainsparkApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ChainsparkApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp start_job({job, supervisor}) do
    Supervisor.start_link([worker(job, [])],
      strategy: :one_for_one,
      name: supervisor
    )
  end
end
