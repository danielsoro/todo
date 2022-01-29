defmodule TodoTest do
  use ExUnit.Case
  doctest TodoList

  test "should create a new todo list" do
    assert TodoList.new() == %{}
  end

  test "should add entry in todo list" do
    assert TodoList.add_entry(%{}, ~D[2022-01-29], "Appoitment") == %{
             ~D[2022-01-29] => ["Appoitment"]
           }
  end
end
