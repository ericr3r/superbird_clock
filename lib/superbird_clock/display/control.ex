defmodule SuperbirdClock.Display.Control do
  require Logger
  use GenServer

  alias SuperbirdClock.Display.Screen

  defstruct last_brightness: 100,
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
    {:ok, %__MODULE__{last_brightness: last_brightness}}
  end

  @impl GenServer
  def handle_call({:brighten, _notify_change}, _from, state) do
    current = Screen.brighten()
    {:reply, {:ok, current}, %__MODULE__{state | last_brightness: current}}
  end

  @impl GenServer
  def handle_call({:dim, _notify_chnage}, _from, state) do
    current = Screen.dim()
    {:reply, {:ok, current}, %__MODULE__{state | last_brightness: current}}
  end

  @impl GenServer
  def handle_call(:get_brightness, _from, state) do
    current = Screen.get_brightness()
    {:reply, {:ok, current}, %__MODULE__{state | last_brightness: current}}
  end

  @impl GenServer
  def handle_call({:set_brightness, level, _notify_change}, _from, state) do
    current = Screen.set_brightness(level)
    {:reply, {:ok, current}, %__MODULE__{state | last_brightness: current}}
  end

  @impl GenServer
  def handle_call({:toggle, _notify_change}, _from, %{last_brightness: last_brightness} = state) do
    {current, last} = Screen.toggle(last_brightness)
    {:reply, {:ok, current}, %__MODULE__{state | last_brightness: last}}
  end

  @impl GenServer
  def handle_info(event, state) do
    Logger.debug("Unhandled event #{inspect(event)}")
    {:reply, :ok, state}
  end
end
