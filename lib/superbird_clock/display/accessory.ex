defmodule SuperbirdClock.Display.Accessory do
  @behaviour HAP.ValueStore

  alias SuperbirdClock.Display.Control
  require Logger

  @impl HAP.ValueStore
  def get_value(:brightness) do
    Control.get_brightness()
  end

  def get_value(:on_off) do
    {:ok, brightness} = Control.get_brightness()
    {:ok, brightness > 0}
  end

  @impl HAP.ValueStore
  def put_value(false, :on_off) do
    {:ok, brightness} = Control.get_brightness()

    if brightness > 0 do
      Control.toggle()
    end

    :ok
  end

  @impl HAP.ValueStore
  def put_value(true, :on_off) do
    {:ok, brightness} = Control.get_brightness()

    if brightness == 0 do
      {:ok, _level} = Control.toggle(false)
    end

    :ok
  end

  @impl HAP.ValueStore
  def put_value(level, :brightness) do
    {:ok, _brightness} = Control.set_brightness(level, false)
    :ok
  end

  @impl HAP.ValueStore
  def put_value(value, opts) do
    Logger.debug("Put value #{inspect(opts)}")
    Logger.debug(inspect(value))
    :ok
  end

  @impl HAP.ValueStore
  def set_change_token(change_token, opts) do
    Logger.debug("Set Change token #{inspect(change_token)} #{inspect(opts)}")
    Control.set_change_token(change_token, opts)
    :ok
  end
end
