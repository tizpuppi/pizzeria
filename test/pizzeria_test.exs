defmodule PizzeriaTest do
  use ExUnit.Case
  doctest Pizzeria

  test "greets the world" do
    assert Pizzeria.hello() == :world
  end
end
