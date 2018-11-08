defmodule Pizzeria.Waiter do
  use GenServer

  @delivery_time_range 1_000..8_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def receive_order(from) do
    GenServer.call(__MODULE__, {:new_order, from})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:new_order, from}, {from_server, _ref}, state) do
    IO.inspect from
    IO.inspect from_server
    time = Enum.random(@delivery_time_range)
    Process.send_after(from, :delivered, time)
    {:reply, :ok, state}
  end
end
