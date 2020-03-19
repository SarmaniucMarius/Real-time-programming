defmodule Distributor do

  def start_link(url) do
    IO.puts("Starting distributor")

    workers = 1..10 |>
    Enum.map(fn id ->
      worker = "Worker #{id}"
      WorkersSupervisor.start_child(worker)
      worker
    end) |> List.to_tuple

    recv_pid = spawn_link(__MODULE__, :recv, [workers, 0])
    {:ok, _eex_pid} = EventsourceEx.new(url, stream_to: recv_pid)

    {:ok, recv_pid}
  end

  def recv(workers, id) do
    id = receive do
      msg ->
        IO.puts("Event received sending to worker #{id}")
        worker = elem(workers, id)
        EventProcessor.process_event(worker, msg.data)
        Process.sleep(1000)
        if id < (tuple_size(workers) - 1) do id + 1 else 1 end
    end
    recv(workers, id)
  end
end
