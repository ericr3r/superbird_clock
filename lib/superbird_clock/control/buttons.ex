defmodule SuperbirdClock.Control.Buttons do
  require Logger
  use GenServer

  alias SuperbirdClock.Control.Screen

  defstruct buttons: nil, last_brightness: 100

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init([]) do
    keys =
      InputEvent.enumerate()
      |> Enum.filter(fn {_, %{name: name}} -> name == "gpio-keys" end)
      |> Enum.map(fn {path, _} -> path end)

    if length(keys) != 1 do
      {:error, :not_found}
    else
      [buttons | _] = keys
      {:ok, _pid} = InputEvent.start_link(buttons)
      {:ok, %__MODULE__{buttons: buttons}}
    end
  end

  @impl GenServer
  def handle_info({:input_event, buttons, events}, %{buttons: buttons} = state) do
    state = handle_events(events, state)
    {:noreply, state}
  end

  defp handle_events([{:ev_key, :key_esc, 1}], %{last_brightness: last_brigthness} = state) do
    Logger.debug("Power event")
    {_current, last} = Screen.toggle(last_brigthness)
    %__MODULE__{state | last_brightness: last}
  end

  defp handle_events(event, state) do
    Logger.debug("Unhandled event #{inspect(event)}")
    state
  end
end
