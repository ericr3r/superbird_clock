defmodule SuperbirdClock.Display.Screen do
  @sys_brightness "/sys/class/backlight/backlight/brightness"

  require Logger

  def get_brightness() do
    with {:ok, brightness} <- File.read(@sys_brightness),
         {value, _} <- Integer.parse(brightness) do
      value
    end
  end

  def set_brightness(value) when value < 0, do: set_brightness(0)

  def set_brightness(value) when value > 100, do: set_brightness(100)

  def set_brightness(value) do
    Logger.debug("Set Brightness #{value}")

    with :ok = File.write(@sys_brightness, "#{value}") do
      get_brightness()
    end
  end

  def dim(), do: set_brightness(get_brightness() - 10)

  def brighten(), do: set_brightness(get_brightness() + 10)

  def toggle(last) do
    toggle(get_brightness(), last)
  end

  defp toggle(0, last), do: {set_brightness(last), last}
  defp toggle(current, _), do: {set_brightness(0), current}
end
