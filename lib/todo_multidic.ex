defmodule MultiDic do
  @spec new :: %{}
  @doc """
  The new function return a new TodoList structure.

  ## Examples

      iex> MultiDic.new()
      %{}

  """
  def new(), do: %{}

  @spec add(%{}, Date, String) :: any
  @doc """
  Function to add new entry to your todo list.

  ## Examples

      iex> MultiDic.add(%{}, ~D[2022-01-29], "Appoitment")
      %{~D[2022-01-29] => ["Appoitment"]}

  """
  def add(todo_list, data, title) do
    Map.update(
      todo_list,
      data,
      [title],
      fn titles -> [title | titles] end
    )
  end

  @spec get(map, Date) :: any
  @doc """
  Function to get entries by date

  ## Examples

      iex> MultiDic.get(%{~D[2022-01-29] => ["Appoitment"]}, ~D[2022-01-29])
      ["Appoitment"]

      iex> MultiDic.get(%{~D[2022-01-29] => ["Appoitment"]}, ~D[2022-01-30])
      nil

  """
  def get(todo_list, data), do: Map.get(todo_list, data)
end
