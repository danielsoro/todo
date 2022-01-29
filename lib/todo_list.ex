defmodule TodoList do
  @moduledoc """
  Documentation for `TodoList`.
  This module define a TodoList when you can configure a list of todo by dates
  """

  @spec new :: %{}
  @doc """
  The new function return a new TodoList structure.

  ## Examples

      iex> TodoList.new()
      %{}

  """
  def new(), do: %{}

  @spec add_entry(%{}, Date, String) :: any
  @doc """
  Function to add new entry to your todo list.

  ## Examples
      iex> TodoList.add_entry(%{}, ~D[2022-01-29], "Appoitment")
      %{~D[2022-01-29] => ["Appoitment"]}

  """
  def add_entry(todo_list, data, title) do
    Map.update(
      todo_list,
      data,
      [title],
      fn titles -> [title | titles] end
    )
  end
end
