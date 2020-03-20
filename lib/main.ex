defmodule Main do
  Application

  def start(_, _) do
    children = [
      %{
        id: WorkersSupervisor,
        start: {WorkersSupervisor, :start_link, []},
        restart: :permanent,
        type: :supervisor
      },
      { Registry, [keys: :unique, name: :workers_registry]},
      %{
        id: Scheduler,
        start: {Scheduler, :start_link, [10]},
        restart: :permanent,
        type: :worker
      },
      %{
        id: Distributor,
        start: {Distributor, :start_link, ["http://localhost:4000/iot"]},
        restart: :permanent,
        type: :worker
      }
    ]

    opts = [strategy: :one_for_one, name: MainSupervisor]
    Supervisor.start_link(children, opts)

    receive do
      {:message_type, value} -> # code
    end

  end
end
