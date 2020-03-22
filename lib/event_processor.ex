defmodule EventProcessor do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, [name], name: get_name(name))
  end

  def process_event(event_processor, event) do
    GenServer.cast(get_name(event_processor), {:process, event})
  end

  @impl true
  def init(name) do
    # IO.puts("Starting #{name}")
    {:ok, name}
  end

  @impl true
  def handle_cast({:process, event}, name) do
    weather_data = Poison.decode!(event)["message"]
    {weather_avg, time_stamp} = calc_weather_avg(weather_data)
    weather_forcast = forcast(
      weather_avg[:pressure], weather_avg[:humidity],
      weather_avg[:light], weather_avg[:temperature],
      weather_avg[:wind]
    )

    Aggregator.send_forcast(Aggregator, {weather_forcast, weather_avg, time_stamp})

    {:noreply, name}
  end

  @impl true
  def terminate(_reason, _state) do
    # IO.puts("Terminating #{state}")
  #   Process.send_after(Scheduler, {:start_worker, state}, 10)
    DynamicSupervisor.terminate_child(WorkersSupervisor, self())
  end

  defp calc_weather_avg(data) do
    pressure_1 = data["atmo_pressure_sensor_1"]
    pressure_2 = data["atmo_pressure_sensor_2"]
    pressure_avg = avg(pressure_1, pressure_2)
    humidity_1 = data["humidity_sensor_1"]
    humidity_2 = data["humidity_sensor_2"]
    humidity_avg = avg(humidity_1, humidity_2)
    light_1 = data["light_sensor_1"]
    light_2 = data["light_sensor_2"]
    light_avg = avg(light_1, light_2)
    temperature_1 = data["temperature_sensor_1"]
    temperature_2 = data["temperature_sensor_2"]
    temperature_avg = avg(temperature_1, temperature_2)
    timestamp = data["unix_timestamp_us"] |> DateTime.from_unix(:microsecond) |> elem(1)
    wind_1 = data["wind_speed_sensor_1"]
    wind_2 = data["wind_speed_sensor_2"]
    wind_avg = avg(wind_1, wind_2)
    {
      %{
        pressure: pressure_avg,
        humidity: humidity_avg,
        light: light_avg,
        temperature: temperature_avg,
        wind: wind_avg
      },
      timestamp
    }
  end

  def forcast(pressure, humidity, light, temperature, wind) do
    cond do
      temperature < -2 && light < 128 && pressure < 720 -> "SNOW"
      temperature < -2 && light > 128 && pressure < 680 -> "WET_SNOW"
      temperature < -8 -> "SNOW"
      temperature < -15 && wind > 45 -> "BLIZZARD"
      temperature > 0 && pressure < 710 && humidity > 70 && wind < 20 -> "SLIGHT_RAIN"
      temperature > 0 && pressure < 690 && humidity > 70 && wind > 20 -> "HEAVY_RAIN"
      temperature > 30 && pressure < 770 && humidity > 80 && light > 192 -> "HOT"
      temperature > 30 && pressure < 770 && humidity > 50 && light > 192 && wind > 35 -> "CONVECTION_OVEN"
      temperature > 25 && pressure < 750 && humidity > 70 && light < 192 && wind < 10 -> "WARM"
      temperature > 25 && pressure < 750 && humidity > 70 && light < 192 && wind > 10 -> "SLIGHT_BREEZE"
      light < 128 -> "CLOUDY"
      temperature > 30 && pressure < 660 && humidity > 85 && wind > 45 -> "MONSOON"
      true -> "JUST_A_NORMAL_DAY"
    end
  end

  defp avg(a, b) do
    (a+b)/2
  end

  defp get_name(name) do
    {:via, Registry, {:workers_registry, name}}
  end
end
