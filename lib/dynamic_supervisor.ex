defmodule MyDynamicSupervisor do
  use DynamicSupervisor

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(id, module, module_fn, module_args) do
    spec = %{
      id: id,
      start: {module, module_fn, module_args},
      restart: :permanent,
      type: :worker
    }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
