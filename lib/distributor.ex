defmodule Distributor do

  def start_link(url) do
    IO.puts("Starting distributor")

    recv_pid = spawn_link(__MODULE__, :recv, [1])
    {:ok, _eex_pid} = EventsourceEx.new(url, stream_to: recv_pid)

    {:ok, recv_pid}
  end

  def recv(id) do
    id = receive do
      msg ->
        # IO.puts("Event received sending to worker #{id}")

        workers = Scheduler.get_workers(Scheduler)
        elem(workers, id-1) |>
        EventProcessor.process_event(msg.data)

        # Process.sleep(100)
        if id < tuple_size(workers) do id + 1 else 1 end
    end
    recv(id)
  end

end
