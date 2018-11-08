defmodule Pizzeria.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      # Pizzeria.Table is a gen server, so it belongs to the worker category
      # The category is determined by child_spec function
      Pizzeria.Table,
      Pizzeria.Waiter
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    #
    # Put the table gen server under a supervision tree.
    # Pizzeria Supervisor will supervise the worker process Pizzeria.Table
    # and will restart based on the strategy
    Supervisor.start_link(children, strategy: :one_for_one, name: Pizzeria.Supervisor)
  end
end
