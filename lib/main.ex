defmodule Main do
  use Application

  def start(_, _) do
    children = [
      {
        Registry,
        [keys: :unique, name: :workers_registry]
      },
      %{
        id: WorkersSupervisor,
        start: {WorkersSupervisor, :start_link, []},
        type: :supervisor
      },
      %{
        id: Distributor,
        start: {Distributor, :start_link, ["http://localhost:4000/iot"]}
      },
      %{
        id: Scheduler,
        start: {Scheduler, :start_link, [30]}
      },
      %{
        id: Aggregator,
        start: {Aggregator, :start_link, [500]}
      },
      %{
        id: Printer,
        start: {Printer, :start_link, []}
      },
      %{
        id: Input,
        start: {Input, :start_link, []}
      }
    ]

    opts = [strategy: :one_for_one, name: MainSupervisor]
    Supervisor.start_link(children, opts)

    receive do
      {:message_type, value} -> # code
    end

  end
end
