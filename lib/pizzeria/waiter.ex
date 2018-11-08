defmodule Pizzeria.Waiter do
  @delivery_time_range 1_000..8_000

  def handle_order(from) do
    time = Enum.random(@delivery_time_range)
    Process.send_after(from, :delivered, time)
  end
end
