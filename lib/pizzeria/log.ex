defmodule Pizzeria.Log do
  import IO.ANSI

  require Logger

  def table_sitting() do
    "Guests sat on the table"
    |> colorize(white())
    |> log
  end

  def table_decision() do
    "Table ordered pizzas, now waiting"
    |> colorize(yellow())
    |> log
  end

  def table_leaving() do
    "Table has waited too long, people decided to leave"
    |> colorize(red())
    |> log
  end

  def delivered() do
    "Table has been served"
    |> colorize(green())
    |> log
  end

  def finished() do
    "Table has finished eating and is now leaving"
    |> colorize(green())
    |> log
  end

  defp colorize(msg, color) do
    [color, msg, white()] |> Enum.join("")
  end

  defp log(msg) do
    Logger.info(fn -> msg end)
  end
end
