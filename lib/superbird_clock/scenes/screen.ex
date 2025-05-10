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
  def get_value(_opts) do
    GenServer.call(__MODULE__, :get)
  end

  @impl HAP.ValueStore
  def put_value(value, _opts) do
    GenServer.call(__MODULE__, {:put, value})
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
  def handle_call(:get, _from, state) do
    value = get_brightness()

    Logger.info("Returning value of #{value} for Brightness")

    {:reply, {:ok, value}, state}
  end

  @impl GenServer
  def handle_call({:put, value}, _from, state) do
    result = set_brightness(value)

    Logger.info("Writing value of #{value} to Brightness (result #{result})")

    {:reply, result, state}
  end

  @impl GenServer
  def handle_call({:set_change_token, change_token}, _from, state) do
    state = %{state | change_token: change_token}
    {:reply, :ok, state}
  end

  def handle_call(
        :toggle,
        _from,
        %__MODULE__{change_token: change_token, last_brightness: last_brigthtness} = state
      ) do
    new_value =
      case get_brightness() do
        0 -> last_brigthtness
        _ -> 0
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
      value
    end
  end

  def set_brightness(value) do
    with :ok = File.write(@sys_brightness, "#{value}") do
      get_brightness()
    end
  end
end
