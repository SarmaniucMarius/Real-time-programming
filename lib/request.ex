defmodule Request do
  def start_link do
    IO.puts("Starting request")
    pid = spawn_link(Request, :loop, [])
    spawn_link(EventsourceEx, :new, ["http://localhost:4000/iot", [{:stream_to, pid}]])
    {:ok, pid}
  end

  def loop do
    receive do
      msg ->
          Poison.decode!(msg.data) |> IO.inspect
          Process.sleep(100)
    end
    loop()
  end
end
