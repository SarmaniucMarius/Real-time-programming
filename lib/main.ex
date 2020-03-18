defmodule Main do
  def start() do
    {:ok, supervisor_pid} = MyDynamicSupervisor.start_link([])

    event_processor_pids = 0..50 |> Enum.map(fn _ ->
      {:ok, pid} = MyDynamicSupervisor.start_child(
        EventProcessor,
        EventProcessor,
        :start_link,
        [])
      pid
    end) |> List.to_tuple

    {:ok, request_pid} = MyDynamicSupervisor.start_child(
      Request,
      Request,
      :start_link,
      [supervisor_pid, event_processor_pids]
    )
    {:ok, eex_pid} = MyDynamicSupervisor.start_child(
      EventsourceEx,
      EventsourceEx,
      :new,
      ["http://localhost:4000/iot", [{:stream_to, request_pid}]]
    )

    spawn(fn ->
      Process.monitor(self())
      receive do
        msg -> IO.inspect(msg)
      end
    end)
    spawn(fn ->
      Process.monitor(request_pid)
      receive do
        msg -> IO.inspect(msg)
      end
    end)
    spawn(fn ->
      Process.monitor(eex_pid)
      receive do
        msg -> IO.inspect(msg)
      end
    end)

    {:ok, supervisor_pid}
  end
end
