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
end
