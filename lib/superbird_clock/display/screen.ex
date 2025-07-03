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
end
