defmodule SuperbirdClock.Display.Screen do
  @sys_brightness "/sys/class/backlight/backlight/brightness"

  require Logger

  def get_brightness() do
    with {:ok, brightness} <- File.read(@sys_brightness),
         {value, _} <- Integer.parse(brightness) do
      value
    end
  end

  def set_brightness(level) when level < 0, do: set_brightness(0)

  def set_brightness(level) when level > 100, do: set_brightness(100)

  def set_brightness(level) do
    with :ok = File.write(@sys_brightness, "#{level}") do
      get_brightness()
    end
  end

  def dim(), do: set_brightness(get_brightness() - 10)

  def brighten(), do: set_brightness(get_brightness() + 10)

  def toggle(last_on_level) do
    toggle(get_brightness(), last_on_level)
  end

  defp toggle(0, last), do: set_brightness(last)
  defp toggle(_current, _), do: set_brightness(0)
end
