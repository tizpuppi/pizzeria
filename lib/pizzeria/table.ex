defmodule Pizzeria.Table do
  use GenServer
  alias Pizzeria.Log

  defstruct phase: :deciding

  @thinking_time_range 1_000..3_000
  @waiting_time 5_000
  @eating_time_range 1_000..3_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: :table)
  end

  def init([]) do
    Log.table_sitting()
    state = %__MODULE__{}
    send(self(), :look_at_menu)
    {:ok, state}
  end

  def handle_info(:look_at_menu, state) do
    time = Enum.random(@thinking_time_range)
    Process.send_after(self(), :decide, time)
    {:noreply, state}
  end

  def handle_info(:decide, state = %__MODULE__{phase: :deciding}) do
    Log.table_decision()
    Pizzeria.Waiter.handle_order(self())
    new_state = %{state | phase: :waiting}
    {:noreply, new_state, @waiting_time}
  end

  def handle_info(:delivered, state) do
    Log.delivered()
    time = Enum.random(@eating_time_range)
    Process.send_after(self(), :finished, time)
    {:noreply, state}
  end

  def handle_info(:finished, state) do
    Log.finished()
    {:stop, :normal, state}
  end

  def handle_info(:timeout, state) do
    Log.table_leaving()
    {:stop, :waited_too_long, state}
  end
end
