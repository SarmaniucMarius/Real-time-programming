defmodule Input do
  def start_link do
    pid = spawn_link(__MODULE__, :get_input, [])
    {:ok, pid}
  end

  def get_input do
    user_input = IO.gets("")

    if user_input === "t\n" do
      :ok = Printer.set_printable(Printer, false)
      new_update_time =
        IO.gets("Introduce forcast update time: ") |>
        String.trim("\n") |>
        Integer.parse |>
        elem(0)
      :ok = Aggregator.update_time(Aggregator, new_update_time)
      :ok = Printer.set_printable(Printer, true)
    end

    get_input()
  end
end
