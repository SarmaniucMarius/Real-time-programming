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
    # IO.puts("Scheduler starts #{workers_count} workers")

    workers = 1..workers_count |>
    Enum.map(fn id ->
      worker = "Worker #{id}"
      WorkersSupervisor.start_child(worker)
      worker
    end) |> List.to_tuple

    Process.send_after(self(), :events, 500)

    {:ok, {workers, workers_count, 0}}
  end

  @impl true
  def handle_info(:events, state) do
    workers = elem(state, 0)
    workers_count = elem(state, 1)
    event_count = elem(state, 2)
    # IO.puts("===================================")
    # IO.puts("Processed events in .5 second: #{event_count}")

    wanted_workers_count = cond do
      event_count <= 100 -> 15
      event_count <= 300 -> 30
      event_count >  300 -> 60
    end
    # IO.puts("Wanted number of workers wanted: #{wanted_workers_count}")
    # number_of_workers_before = tuple_size(workers)
    # IO.puts("Number of workers before: #{number_of_workers_before}")
    # number_of_supervisor_children_before =
    #   DynamicSupervisor.which_children(WorkersSupervisor) |>
    #   length
    # IO.puts("Number of supervisor children before: #{number_of_supervisor_children_before}")
    total_workers_count =  wanted_workers_count - workers_count
    workers = cond do
      total_workers_count > 0 ->
        1..workers_count+total_workers_count |>
        Enum.map(fn id ->
          worker = "Worker #{id}"
          WorkersSupervisor.start_child(worker)
          worker
        end) |> List.to_tuple

      total_workers_count < 0 ->
        workers_count+total_workers_count+1..workers_count |>
        Enum.map(fn id ->
          worker = "Worker #{id}"
          worker_list = Registry.lookup(:workers_registry, worker)
          if length(worker_list) > 0 do
            hd(worker_list) |> elem(0) |>
            WorkersSupervisor.delete_child
          end
        end)

        1..workers_count+total_workers_count |>
        Enum.map(fn id ->
          worker = "Worker #{id}"
          WorkersSupervisor.start_child(worker)
          worker
        end) |> List.to_tuple
      true -> workers # if total_workers_count = 0 do nothing
    end
    # number_of_workers_after = tuple_size(workers)
    # IO.puts("Number of workers after: #{number_of_workers_after}")
    # number_of_supervisor_children_after =
    #   DynamicSupervisor.which_children(WorkersSupervisor) |>
    #   length
    # IO.puts("Number of supervisor children after: #{number_of_supervisor_children_after}")
    # IO.puts("===================================")

    Process.send_after(self(), :events, 500)
    {:noreply, {workers, wanted_workers_count, 0}}
  end

  @impl true
  def handle_info({:start_worker, worker_name}, state) do
    WorkersSupervisor.start_child(worker_name)
    {:noreply, state}
  end

  @impl true
  def handle_call(:get_workers, _, state) do
    workers = elem(state, 0)
    workers_count = elem(state, 1)
    event_count = elem(state, 2) + 1
    {:reply, workers, {workers, workers_count, event_count}}
  end
end
