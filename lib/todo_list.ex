defmodule TodoServer do
  def start do
    spawn(fn -> loop(TodoList.new()) end)
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  def update_entry(todo_server, entry) do
    send(todo_server, {:update_entry, entry})
  end

  def delete_entry(todo_server, entry) do
    send(todo_server, {:delete_entry, entry})
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:update_entry, entry}) do
    TodoList.update_entry(todo_list, entry)
    todo_list
  end

  defp process_message(todo_list, {:delete_entry, entry}) do
    TodoList.delete_entry(todo_list, entry)
    todo_list
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end
end

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
  def import(file_name) do
    file_name
    |> read_lines
    |> create_entries
    |> TodoList.new()
  end

  defp read_lines(file_name) do
    File.stream!(file_name)
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  defp create_entries(lines) do
    lines
    |> Stream.map(&extract_fields/1)
    |> Stream.map(&create_entry/1)
  end

  defp extract_fields(line) do
    line
    |> String.split(",")
    |> convert_date
  end

  defp convert_date([date_string, title]) do
    {parse_date(date_string), title}
  end

  defp parse_date(date_string) do
    [year, month, day] =
      date_string
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)
    date
  end

  defp create_entry({date, title}) do
    %{date: date, title: title}
  end
end
