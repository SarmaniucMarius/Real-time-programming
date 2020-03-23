defmodule Printer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def print_forcast(printer, forcast) do
    GenServer.call(printer, {:print_forcast, forcast})
  end

  def set_printable(printer, new_state) do
    GenServer.call(printer, {:set_printable, new_state})
  end

  @impl true
  def init(_) do
    {:ok, true}
  end

  def handle_call({:set_printable, new_state}, _from, _is_printable) do
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:print_forcast, data}, _from, is_printable) do
    if is_printable === true do
      forcast = elem(data, 0)
      sensors_data = elem(data, 1)
      time_stamp = elem(data, 2) |> DateTime.add(7200, :second)
      humidity = sensors_data[:humidity] |> Float.round(2)
      light = sensors_data[:light] |> Float.round(2)
      pressure = sensors_data[:pressure] |> Float.round(2)
      temperature = sensors_data[:temperature] |> Float.round(2)
      wind = sensors_data[:wind] |> Float.round(2)
      IO.puts("=================================")
      IO.puts("FORCAST ON #{time_stamp.day}.#{time_stamp.month}.#{time_stamp.year}, AT #{time_stamp.hour}:#{time_stamp.minute}:#{time_stamp.second}")
      IO.puts("---------------------------------")
      IO.puts("#{forcast}")
      IO.puts("---------------------------------")
      IO.puts("Humidity: #{humidity}")
      IO.puts("Light: #{light}")
      IO.puts("Pressure: #{pressure}")
      IO.puts("Temperature: #{temperature}")
      IO.puts("Wind: #{wind}")
      IO.puts("=================================")
    end
    {:reply, :ok, is_printable}
  end
end
