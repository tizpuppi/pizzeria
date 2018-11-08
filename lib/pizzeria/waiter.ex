defmodule Pizzeria.Waiter do
  use GenServer

  @delivery_time_range 1_000..8_000

  # Called from the supervisor
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Public interface.
  # Behind the scene Waiter is a supervised process
  # Perform a synchronous call
  def receive_order() do
    GenServer.call(__MODULE__, :new_order)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:new_order, {from, _ref}, state) do
    time = Enum.random(@delivery_time_range)
    Process.send_after(from, :delivered, time)
    # Return waiting time
    # At the moment the reply is not used
    {:reply, time, state}
  end
end
