defmodule Request do
  def start_link(supervisor_pid, _event_processors) do
    IO.puts("Starting request")

    # request_pid = spawn_link(
    #   Request,
    #   :loop,
    #   [supervisor_pid, event_processors, 0, 0, 0]
    # )

    request_pid = spawn_link(
      Request,
      :loop,
      [supervisor_pid, 0, 0]
    )

    {:ok, request_pid}
  end

  def loop(supervisor, id, event_counter) do
    id = receive do
      msg ->
        children = DynamicSupervisor.which_children(supervisor)
        event_processors = Enum.filter(children, fn child ->
          match?({_, _, :worker, [EventProcessor]}, child)
        end) |>
        Enum.map(fn tuple ->
          elem(tuple, 1)
        end) |>
        List.to_tuple

        IO.puts("Event recieved sending to actor #{id}")
        event_processor = elem(event_processors, id)
        send(event_processor, {self(), msg.data})
        # Process.sleep(50)
        if id >= 50 do 0 else id + 1 end
    end
    event_counter = event_counter + 1
    IO.inspect("Event counter = #{event_counter}")
    loop(supervisor, id, event_counter)
  end

  # def loop(supervisor, event_processors, id, event_counter, panic_counter) do
  #   {event_processors, id, panic_counter} = receive do
  #     msg ->
  #       IO.puts("Event recieved sending to actor #{id}")
  #       event_processor = elem(event_processors, id)
  #       send(event_processor, {self(), msg.data})
  #       id = if id >= 4 do 0 else id + 1 end
  #       Process.sleep(50)

  #       receive do
  #         :ok -> IO.puts("Event processed")
  #         {event_processors, id, panic_counter}
  #       after 100 ->
  #         IO.puts("Event not processed, getting new event_processor")

  #         children = DynamicSupervisor.which_children(supervisor)
  #         new_pids = Enum.filter(children, fn child ->
  #           match?({_, _, :worker, [EventProcessor]}, child)
  #         end) |>
  #         Enum.map(fn tuple ->
  #           elem(tuple, 1)
  #         end) |> List.to_tuple

  #         {new_pids, id, panic_counter+1}
  #       end
  #   end
  #   event_counter = event_counter + 1
  #   IO.inspect("Event counter = #{event_counter}")
  #   IO.inspect("Panic counter = #{panic_counter}")
  #   loop(supervisor, event_processors, id, event_counter, panic_counter)
  # end
end
