defmodule Main do
  def start() do
    MyDynamicSupervisor.start_link([])
    MyDynamicSupervisor.start_child(
      Request,
      Request,
      :start_link,
      []
    )
  end
end
