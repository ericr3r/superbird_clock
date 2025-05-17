defmodule SuperbirdClock.Control.Buttons do
  require Logger
  use GenServer

  alias SuperbirdClock.Control.Screen

  defstruct buttons: nil,
            rotary: nil,
            last_brightness: 100

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init([]) do
    with {:ok, buttons} <- get_buttons(),
         {:ok, rotary} <- get_rotary(),
         {:ok, _} = InputEvent.start_link(buttons),
         {:ok, _} = InputEvent.start_link(rotary) do
      {:ok, %__MODULE__{buttons: buttons, rotary: rotary}}
    end
  end

  @impl GenServer
  def handle_info({:input_event, buttons, events}, %{buttons: buttons} = state) do
    state = handle_events(events, state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:input_event, rotary, events}, %{rotary: rotary} = state) do
    state = handle_events(events, state)
    {:noreply, state}
  end

  defp get_buttons() do
    keys =
      InputEvent.enumerate()
      |> Enum.filter(fn {_, %{name: name}} -> name == "gpio-keys" end)
      |> Enum.map(fn {path, _} -> path end)

    if length(keys) != 1 do
      {:error, :buttons_not_found}
    else
      {:ok, hd(keys)}
    end
  end

  defp get_rotary() do
    encoders =
      InputEvent.enumerate()
      |> Enum.filter(fn {_, %{name: name}} -> name == "rotary@0" end)
      |> Enum.map(fn {path, _} -> path end)

    if length(encoders) != 1 do
      {:error, :rotary_not_found}
    else
      {:ok, hd(encoders)}
    end
  end

  defp handle_events([{:ev_key, :key_esc, 1}], %{last_brightness: last_brigthness} = state) do
    {_current, last} = Screen.toggle(last_brigthness)
    %__MODULE__{state | last_brightness: last}
  end

  defp handle_events([{:ev_rel, :rel_hwheel, 1}], state) do
    brightness = Screen.increase()
    %__MODULE__{state | last_brightness: brightness}
  end

  defp handle_events([{:ev_rel, :rel_hwheel, -1}], state) do
    brightness = Screen.decrease()
    %__MODULE__{state | last_brightness: brightness}
  end

  defp handle_events(event, state) do
    Logger.debug("Unhandled event #{inspect(event)}")
    state
  end
end
