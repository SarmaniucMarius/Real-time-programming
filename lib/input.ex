defmodule Input do
  def start_link do
    pid = spawn_link(__MODULE__, :get_input, [])
    {:ok, pid}
  end

  def get_input do
    new_update_time = IO.gets("") |> String.trim("\n") |> Integer.parse |> elem(0)

    :ok = Aggregator.update_time(Aggregator, new_update_time)

    get_input()
  end
end
