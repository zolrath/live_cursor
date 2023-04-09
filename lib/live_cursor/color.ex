defmodule LiveCursor.Color do
  @doc """
  Get a random HSL color based off the input string.
  """
  def getHSL(s) do
    hue = to_charlist(s) |> Enum.sum() |> rem(360)
    "hsl(#{hue}, 70%, 40%)"
  end
end
