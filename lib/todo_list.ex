defmodule TodoList do
  defstruct auto_id: 1, entries: %{}
  @moduledoc """
  Documentation for `TodoList`.
  This module define a TodoList when you can configure a list of todo by dates
  """

  @spec new :: %TodoList{auto_id: 1, entries: %{}}
  @doc """
  The new function return a new TodoList structure.

  ## Examples

      iex> TodoList.new()
      %TodoList{auto_id: 1, entries: %{}}

  """
  def new(), do: %TodoList{}

  @spec add_entry(%TodoList{auto_id: number, entries: map}, map) :: %TodoList{auto_id: number, entries: map}
  @doc """
  Function to add new entry to your todo list.

  ## Examples

      iex> TodoList.add_entry(%TodoList{}, %{date: ~D[2022-01-29], title: "Appoitment"})
      %TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}

  """
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

    %TodoList{todo_list |
    entries: new_entries,
    auto_id: todo_list.auto_id + 1
  }
  end

  @spec entries(%TodoList{auto_id: number, entries: map}, Date) :: [map()]
  @doc """
  Function to get entries by date

  ## Examples

      iex> TodoList.entries(%TodoList{auto_id: 3, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}, 2 => %{id: 2, date: ~D[2022-01-29], title: "Meeting"}}}, ~D[2022-01-29])
      [%{id: 1, date: ~D[2022-01-29], title: "Appoitment"}, %{id: 2, date: ~D[2022-01-29], title: "Meeting"}]

      iex> TodoList.entries(%TodoList{auto_id: 3, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}, 2 => %{id: 2, date: ~D[2022-01-29], title: "Meeting"}}}, ~D[2022-01-30])
      []

  """
  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end
end
