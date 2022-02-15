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

      iex> TodoList.new([%{date: ~D[2022-01-29], title: "Appoitment"}])
      %TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}
  """
  def new(entries \\ []), do: Enum.reduce(entries, %TodoList{}, &add_entry(&2, &1))

  @spec add_entry(%TodoList{auto_id: number, entries: map}, map) :: %TodoList{
          auto_id: number,
          entries: map
        }
  @doc """
  Function to add new entry to your todo list.

  ## Examples

      iex> TodoList.add_entry(%TodoList{}, %{date: ~D[2022-01-29], title: "Appoitment"})
      %TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}

  """
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  @spec update_entry(%TodoList{auto_id: number, entries: map}, %{
          :id => number,
          optional(any) => any
        }) :: %TodoList{auto_id: number, entries: map}
  @doc """
  Update entry based in a new entry

  ## Examples

      iex> TodoList.update_entry(%TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}, %{id: 1, date: ~D[2018-12-20], title: "Appoitment"})
      %TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2018-12-20], title: "Appoitment"}}}

      iex> TodoList.update_entry(%TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}, %{id: 2, date: ~D[2018-12-20], title: "Appoitment"})
      %TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}

  """
  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  @spec update_entry(%TodoList{auto_id: number, entries: map}, number, function()) :: %TodoList{
          auto_id: number,
          entries: map
        }
  @doc """
  Function to update a entry in the todo list

  ## Examples

      iex> TodoList.update_entry(%TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}, 1, &Map.put(&1, :date, ~D[2018-12-20]))
      %TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2018-12-20], title: "Appoitment"}}}

      iex> TodoList.update_entry(%TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}, 2, &Map.put(&1, :date, ~D[2018-12-20]))
      %TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}

  """
  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  @spec delete_entry(%TodoList{auto_id: number, entries: map}, number) :: %TodoList{
          auto_id: number,
          entries: map
        }
  @doc """
  This function will remove a entry from the entries list

  ## Example

      iex> TodoList.delete_entry(%TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}, 1)
      %TodoList{auto_id: 2, entries: %{}}

      iex> TodoList.delete_entry(%TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}, 10)
      %TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}}}

  """
  def delete_entry(todo_list, entry_id) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        %TodoList{todo_list | entries: Map.delete(todo_list.entries, old_entry.id)}
    end
  end

  @spec entries(%TodoList{auto_id: number, entries: map}, Date) :: [map()]
  @doc """
  Function to get entries by date

  ## Examples

      iex> TodoList.entries(%TodoList{auto_id: 2, entries: %{1 => %{id: 1, date: ~D[2022-01-29], title: "Appoitment"}, 2 => %{id: 2, date: ~D[2022-01-29], title: "Meeting"}}}, ~D[2022-01-29])
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

defmodule TodoList.CvsImporter do
  @spec import(any) :: nil
  def import(file) do
    File.stream!(file)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&create_entry(&1))
    |> Enum.to_list()
    |> TodoList.new()
  end

  defp create_entry(list) do
    [year, month, day] =
      Enum.at(list, 0)
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)

    date = Date.new!(year, month, day)
    %{date: date, title: Enum.at(list, 1)}
  end
end
