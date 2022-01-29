defmodule TodoTest do
  use ExUnit.Case
  doctest TodoList

  test "should create a new todo list" do
    assert TodoList.new() == %{}
  end
end
