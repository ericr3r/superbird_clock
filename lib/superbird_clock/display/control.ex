defmodule SuperbirdClock.Display.Control do
  require Logger
  use GenServer
  use Resolve

  alias SuperbirdClock.Display.Screen

  defstruct on: true,
            last_brightness: 100,
            change_tokens: %{}

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

  def set_change_token(change_token, opts) do
    GenServer.call(__MODULE__, {:set_change_token, change_token, opts})
  end

  def toggle(notify_change \\ true) do
    GenServer.call(__MODULE__, {:toggle, notify_change})
  end

  @impl GenServer
  def init([]) do
    last_brightness = resolve(Screen).get_brightness()
    on = last_brightness > 0
    {:ok, %__MODULE__{last_brightness: last_brightness, on: on}}
  end

  @impl GenServer
  def handle_call({:brighten, notify_change}, from, state) do
    current = resolve(Screen).get_brightness()
    handle_call({:set_brightness, current + 10, notify_change}, from, state)
  end

  @impl GenServer
  def handle_call({:dim, notify_change}, from, state) do
    current = resolve(Screen).get_brightness()
    handle_call({:set_brightness, current - 10, notify_change}, from, state)
  end

  @impl GenServer
  def handle_call(:get_brightness, _from, state) do
    current = resolve(Screen).get_brightness()
    {:reply, {:ok, current}, update_state(current, state, false)}
  end

  @impl GenServer
  def handle_call({:set_brightness, level, notify_change}, from, state) when level > 100 do
    handle_call({:set_brightness, 100, notify_change}, from, state)
  end

  @impl GenServer
  def handle_call({:set_brightness, level, notify_change}, from, state) when level < 0 do
    handle_call({:set_brightness, 0, notify_change}, from, state)
  end

  @impl GenServer
  def handle_call({:set_brightness, level, notify_change}, _from, state) do
    Logger.debug("Set brightness #{level}")
    current = resolve(Screen).set_brightness(level)
    {:reply, {:ok, current}, update_state(current, state, notify_change)}
  end

  @impl GenServer
  def handle_call(
        {:set_change_token, change_token, opts},
        _from,
        %__MODULE__{change_tokens: change_tokens} = state
      ) do
    change_tokens = Map.put(change_tokens, opts, change_token)
    state = %{state | change_tokens: change_tokens}
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:toggle, notify_change}, from, %{last_brightness: last_brightness} = state) do
    current = resolve(Screen).get_brightness()

    case {current, last_brightness} do
      {0, last_brightness} ->
        handle_call({:set_brightness, last_brightness, notify_change}, from, state)

      {_, _} ->
        handle_call({:set_brightness, 0, notify_change}, from, state)
    end
  end

  @impl GenServer
  def handle_info(event, state) do
    Logger.debug("Unhandled event #{inspect(event)}")
    {:noreply, state}
  end

  defp update_state(
         current_brightness,
         %__MODULE__{on: previous_on, last_brightness: last_brightness} = state,
         notify_change
       ) do
    on = current_brightness > 0

    brightness =
      case current_brightness do
        0 -> last_brightness
        _ -> current_brightness
      end

    if notify_change do
      changed({previous_on, last_brightness}, {on, brightness}, state)
    end

    %{state | on: on, last_brightness: brightness}
  end

  defp changed(
         {previous_on, previous_brightness},
         {on, brightness},
         %__MODULE__{change_tokens: change_tokens} =
           _state
       ) do
    if previous_on != on do
      notify(Map.get(change_tokens, :on_off))
    end

    if on && previous_brightness != brightness do
      notify(Map.get(change_tokens, :brightness))
    end

    if !previous_on && on do
      notify(Map.get(change_tokens, :brightness))
    end
  end

  # skip notification for empty change token
  defp notify(nil), do: Logger.debug("Skip notification for empty change token")

  defp notify(change_token), do: HAP.value_changed(change_token)
end
