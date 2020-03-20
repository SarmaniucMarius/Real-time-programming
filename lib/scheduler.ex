defmodule Scheduler do
  use GenServer

  def start_link(workers_count) do
    GenServer.start_link(__MODULE__, workers_count, name: Scheduler)
  end

  def get_workers(scheduler_pid) do
    GenServer.call(scheduler_pid, :get_workers)
  end

  @impl true
  def init(workers_count) do
    IO.puts("Starting scheduler")
    IO.puts("Scheduler starts #{workers_count} workers")

    workers = 1..workers_count |>
    Enum.map(fn id ->
      worker = "Worker #{id}"
      WorkersSupervisor.start_child(worker)
      worker
    end) |> List.to_tuple

    Process.send_after(self(), :events, 1000)

    {:ok, {workers, 0}}
  end

  @impl true
  def handle_info(:events, state) do
    event_count = elem(state, 1)
    IO.puts("===================================")
    IO.puts("Processed events in 1 second: #{event_count}")
    IO.puts("===================================")
    Process.send_after(self(), :events, 1000)
    {:noreply, {elem(state, 0), 0}}
  end

  @impl true
  def handle_call(:get_workers, _, state) do
    workers = elem(state, 0)
    event_count = elem(state, 1) + 1
    {:reply, workers, {workers, event_count}}
  end
end
