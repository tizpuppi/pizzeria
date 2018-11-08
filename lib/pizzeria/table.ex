defmodule Pizzeria.Table do
  use GenServer
  # We use some alias to avoid too much typing
  # Log module puts some color on the terminal
  alias Pizzeria.Log

  # This stuct will contain the state of our gen server
  # Similar to a map, with some default and validation
  defstruct phase: :deciding

  # Some constant. Those are evaluated at compile time
  @thinking_time_range 1_000..3_000
  @waiting_time 5_000
  @eating_time_range 1_000..3_000

  # This is called from Supervisor
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Public interface
  def look_at_menu() do
    GenServer.cast(__MODULE__, :look_at_menu)
  end

  # This is the callback for start_link function.
  # Here we set the state and trigger next step
  # by sending a message to the process
  def init([]) do
    Log.table_sitting()
    # Use default value 
    state = %__MODULE__{}
    look_at_menu()
    {:ok, state}
  end

  # This handles the asyncrhonous call ":look_at_menu"
  # called from the public interface "look_at_menu()"
  def handle_cast(:look_at_menu, state) do
    time = Enum.random(@thinking_time_range)
    # Send a message to the process, now after a timeout
    Process.send_after(self(), :decide, time)
    {:noreply, state}
  end

  # Handler for the ":decide" message.
  # The handler is selected using what is called pattern matching
  # Pattern matching also used on state variable
  # The returned expression has a 3rd argument, which set up a timeout
  # If no new message is received by the process within this timeout,
  # a message ":timeout" is sent to the process itself
  def handle_info(:decide, state = %__MODULE__{phase: :deciding}) do
    Log.table_decision()
    Pizzeria.Waiter.receive_order()
    new_state = %{state | phase: :waiting}
    {:noreply, new_state, @waiting_time}
  end

  # Pizza delivered and eating! :)
  def handle_info(:delivered, state) do
    Log.delivered()
    time = Enum.random(@eating_time_range)
    Process.send_after(self(), :finished, time)
    {:noreply, state}
  end

  # the return expression is a 3 element tuple that contains the atom ":stop"
  # which stop the current process with reason :normal
  # :normal stops the process gracefully and does not log any error
  def handle_info(:finished, state) do
    Log.finished()
    {:stop, :normal, state}
  end

  # This is the callback executed in case of timeout
  # It stops the gen server process in an abnormal way (reason not :normal or :shutdown)
  # thus an error is logged. In both cases the process is supervised, and restarted
  # (see Pizzeria.Application)
  def handle_info(:timeout, state) do
    Log.table_leaving()
    {:stop, :waited_too_long, state}
  end
end
