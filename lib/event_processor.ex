defmodule EventProcessor do
  def start_link() do
    IO.puts("Starting event processor")
    pid = spawn_link(__MODULE__, :loop, [])
    {:ok, pid}
  end

  def loop() do
    receive do
      {_sender, msg} ->
        Poison.decode!(msg)
        # send(sender, :ok)
    end
    loop()
  end
  # use GenServer

  # def start_link do
  #   IO.puts("Starting event processor")

  #   GenServer.start(__MODULE__, nil, name: :event_processor)
  # end

  # @impl true
  # def init(_) do
  #   {:ok, %{}}
  # end

  # def process_event(event_processor_pid, event) do
  #   GenServer.call(event_processor_pid, {:process_event, event})
  # end

  # @impl true
  # def handle_call({:process_event, event}, _ , _) do
  #   Poison.decode!(event.data) |> IO.inspect
  #   {:reply, event, %{}}
  # end
end
