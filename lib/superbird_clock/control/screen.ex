defmodule SuperbirdClock.Control.Screen do
  @sys_brightness "/sys/class/backlight/backlight/brightness"

  require Logger

  def get_brightness() do
    with {:ok, brightness} <- File.read(@sys_brightness),
         {value, _} <- Integer.parse(brightness) do
      value
    end
  end

  def set_brightness(value) do
    Logger.debug("Set Brightness #{value}")

    with :ok = File.write(@sys_brightness, "#{value}") do
      get_brightness()
    end
  end

  def toggle(last) do
    toggle(get_brightness(), last)
  end

  defp toggle(0, last), do: {set_brightness(last), last}
  defp toggle(current, _), do: {set_brightness(0), current}
end
