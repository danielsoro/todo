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
  def new(), do: MultiDic.new()

  @spec add_entry(map, %{date: Date, title: String}) :: %{Date => [%{date: Date, title: String}]}
  @doc """
  Function to add new entry to your todo list.

  ## Examples

      iex> TodoList.add_entry(%{}, %{date: ~D[2022-01-29], title: "Appoitment"})
      %{~D[2022-01-29] => [%{date: ~D[2022-01-29], title: "Appoitment"}]}

  """
  def add_entry(todo_list, entry) do
    MultiDic.add(todo_list, entry.date, entry)
  end

  @spec entries(map, Date) :: %{Date => %{date: Date, title: String}}
  @doc """
  Function to get entries by date

  ## Examples

      iex> TodoList.entries(%{~D[2022-01-29] => [%{date: ~D[2022-01-29], title: "Appoitment"}, %{date: ~D[2022-01-29], title: "Meeting"}]}, ~D[2022-01-29])
      [%{date: ~D[2022-01-29], title: "Appoitment"}, %{date: ~D[2022-01-29], title: "Meeting"}]

      iex> TodoList.entries(%{~D[2022-01-29] => [%{date: ~D[2022-01-29], title: "Appoitment"}]}, ~D[2022-01-30])
      nil

  """
  def entries(todo_list, data), do: MultiDic.get(todo_list, data)
end
