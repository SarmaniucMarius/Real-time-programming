defmodule WorkersSupervisor do
  use DynamicSupervisor

  def start_link do
    IO.puts("Starting workers supervisor")
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(name) do
    spec = %{
      id: EventProcessor,
      start: {EventProcessor, :start_link, [name]},
      type: :worker
    }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
