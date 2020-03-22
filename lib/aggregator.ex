defmodule Aggregator do
  use GenServer

  def start_link(update_time) do
    GenServer.start_link(__MODULE__, update_time, name: __MODULE__)
  end

  def send_forcast(aggregator, forcast) do
    GenServer.cast(aggregator, {:send_forcast, forcast})
  end

  def update_time(aggregator, new_time) do
    GenServer.call(aggregator, {:update_time, new_time})
  end

  @impl true
  def init(update_time) do
    IO.puts("Starting aggregator")

    Process.send_after(self(), :calc_forcast, update_time)

    {:ok, {[], update_time}}
  end

  @impl true
  def handle_cast({:send_forcast, forcast}, state) do
    forcast_list = elem(state, 0) ++ [Tuple.to_list(forcast)]
    update_time = elem(state, 1)
    {:noreply, {forcast_list, update_time}}
  end

  @impl true
  def handle_call({:update_time, new_time}, _from, state) do
    {:reply, :ok, {elem(state, 0), new_time}}
  end

  @impl true
  def handle_info(:calc_forcast, state) do
    update_time = elem(state, 1)
    state = elem(state, 0)
    time_stamp = hd(state) |> List.to_tuple |> elem(2)

    forcast =
      Enum.map(state, fn elem -> hd(elem) end) |>
      Enum.frequencies |>
      Map.to_list |>
      Enum.sort_by(&(elem(&1, 1)), :desc) |> hd |> elem(0)

    sensors_data =
      Enum.filter(state, fn elem -> hd(elem) === forcast end) |>
      Enum.map(fn list -> List.to_tuple(list) end) |>
      Enum.map(fn tuple -> elem(tuple, 1) end) |> List.to_tuple
    accumulator = %{
      humidity: 0,
      light: 0,
      pressure: 0,
      temperature: 0,
      wind: 0
    }
    sensors_data_avg =
      add_sensors_data(
        sensors_data,
        tuple_size(sensors_data)-1,
        accumulator
      ) |>
      Enum.map(fn {sensor, value} ->
        {sensor, value/tuple_size(sensors_data)}
      end) |>
      Enum.into(%{})

    :ok = Printer.print_forcast(Printer, {forcast, sensors_data_avg, time_stamp})

    Process.send_after(self(), :calc_forcast, update_time)
    {:noreply, {[], update_time}}
  end

  defp add_sensors_data(data, length, accumulator) do
    if length >= 0 do
      sensors_data = elem(data, length)

      humidity = accumulator[:humidity] + sensors_data[:humidity]
      light = accumulator[:light] + sensors_data[:light]
      pressure = accumulator[:pressure] + sensors_data[:pressure]
      temperature = accumulator[:temperature] + sensors_data[:temperature]
      wind = accumulator[:wind] + sensors_data[:wind]

      result = %{
        humidity: humidity,
        light: light,
        pressure: pressure,
        temperature: temperature,
        wind: wind
      }

      add_sensors_data(data, length-1, result)
    else
      accumulator
    end
  end
end
