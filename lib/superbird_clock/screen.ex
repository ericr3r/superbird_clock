defmodule SuperbirdClock.Screen do
  alias HAP.Characteristics.Brightness
  @behaviour HAP.ValueStore

  use GenServer

  @sys_brightness "/sys/class/backlight/backlight/brightness"

  defstruct last_brightness: 0, change_token: nil

  require Logger

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl HAP.ValueStore
  def get_value(opts) do
    GenServer.call(__MODULE__, {:get, opts})
  end

  @impl HAP.ValueStore
  def put_value(value, opts) do
    GenServer.call(__MODULE__, {:put, value, opts})
  end

  @impl HAP.ValueStore
  def set_change_token(change_token, opts) do
    GenServer.call(__MODULE__, {:set_change_token, change_token, opts})
  end

  @impl GenServer
  def init(_) do
    {:ok, %__MODULE__{last_brightness: get_brightness()}}
  end

  def toggle() do
    GenServer.call(__MODULE__, :toggle)
  end

  @impl GenServer
  def handle_call({:get, _opts}, _from, state) do
    brightness = get_brightness()

    value = if brightness == 0, do: 0, else: 1
    Logger.info("Returning value of #{value} for On/Off")

    {:reply, {:ok, value}, state}
  end

  @impl GenServer
  def handle_call({:put, value, _opts}, _from, %{last_brightness: last_brightness} = state) do
    brightness = if value == false || value == 0, do: 0, else: last_brightness
    on_off = if value == false || value == 0, do: 0, else: 1

    set_brightness(brightness)
    Logger.info("Writing value of #{on_off} to On_Off ")

    {:reply, on_off, state}
  end

  @impl GenServer
  def handle_call({:set_change_token, change_token, _opts}, _from, state) do
    state = %{state | change_token: change_token}
    {:reply, :ok, state}
  end

  def handle_call(
        :toggle,
        _from,
        %__MODULE__{change_token: change_token, last_brightness: last_brightness} = state
      ) do
    current = get_brightness()

    new_value =
      case current do
        # Default to 100% if no previous value
        0 ->
          last_brightness || 100

        _ ->
          # Store current brightness before turning off
          state = %{state | last_brightness: current}
          0
      end

    set_brightness(new_value)

    if !is_nil(change_token) do
      HAP.value_changed(change_token)
    end

    {:reply, :ok, state}
  end

  def get_brightness() do
    with {:ok, brightness} <- File.read(@sys_brightness),
         {value, _} <- Integer.parse(brightness) do
      # Normalize to 0-100 range expected by HomeKit
      # Assuming system brightness max is 255, adjust if different
      system_max = 255
      trunc(value / system_max * 100)
    end
  end

  def set_brightness(value) do
    # Convert from HomeKit's 0-100 scale to system's scale
    # Assuming system brightness max is 255, adjust if different
    system_max = 255
    system_value = trunc(value / 100 * system_max)

    with :ok = File.write(@sys_brightness, "#{system_value}") do
      get_brightness()
    end
  end
end
