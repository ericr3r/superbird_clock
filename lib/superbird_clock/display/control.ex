defmodule SuperbirdClock.Display.Control do
  require Logger
  use GenServer

  alias SuperbirdClock.Display.Screen

  defstruct on: true,
            last_brightness: 100,
            change_token: nil

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def brighten(notify_change \\ true) do
    GenServer.call(__MODULE__, {:brighten, notify_change})
  end

  def get_brightness() do
    GenServer.call(__MODULE__, :get_brightness)
  end

  def dim(notify_change \\ true) do
    GenServer.call(__MODULE__, {:dim, notify_change})
  end

  def set_brightness(level, notify_change \\ true) do
    GenServer.call(__MODULE__, {:set_brightness, level, notify_change})
  end

  def toggle(notify_change \\ true) do
    GenServer.call(__MODULE__, {:toggle, notify_change})
  end

  @impl GenServer
  def init([]) do
    last_brightness = Screen.get_brightness()
    on = last_brightness > 0
    {:ok, %__MODULE__{last_brightness: last_brightness, on: on}}
  end

  @impl GenServer
  def handle_call({:brighten, _notify_change}, _from, state) do
    current = Screen.brighten()
    {:reply, {:ok, current}, update_state(current, state)}
  end

  @impl GenServer
  def handle_call({:dim, _notify_chnage}, _from, state) do
    current = Screen.dim()
    {:reply, {:ok, current}, update_state(current, state)}
  end

  @impl GenServer
  def handle_call(:get_brightness, _from, state) do
    current = Screen.get_brightness()
    {:reply, {:ok, current}, update_state(current, state)}
  end

  @impl GenServer
  def handle_call({:set_brightness, level, _notify_change}, _from, state) do
    Logger.debug("Set brightness #{level}")
    current = Screen.set_brightness(level)
    {:reply, {:ok, current}, update_state(current, state)}
  end

  @impl GenServer
  def handle_call({:toggle, _notify_change}, _from, %{last_brightness: last_brightness} = state) do
    Logger.debug("Toggle Last #{last_brightness}")
    current = Screen.toggle(last_brightness)
    Logger.debug("Toggle #{current} #{last_brightness}")
    {:reply, {:ok, current}, %__MODULE__{state | last_brightness: last_brightness}}
  end

  @impl GenServer
  def handle_info(event, state) do
    Logger.debug("Unhandled event #{inspect(event)}")
    {:reply, :ok, state}
  end

  defp update_state(current_brightness, %__MODULE__{last_brightness: last_brightness} = state) do
    on = current_brightness > 0

    brightness =
      case current_brightness do
        0 -> last_brightness
        _ -> current_brightness
      end

    %{state | on: on, last_brightness: brightness}
  end
end
