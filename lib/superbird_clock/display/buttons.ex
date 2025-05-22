defmodule SuperbirdClock.Display.Buttons do
  require Logger
  use GenServer

  alias SuperbirdClock.Display.Control

  defstruct buttons: nil,
            rotary: nil

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
    handle_events(events)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:input_event, rotary, events}, %{rotary: rotary} = state) do
    handle_events(events)
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

  defp handle_events([{:ev_key, :key_esc, 1}]) do
    {:ok, _} = Control.toggle()
  end

  defp handle_events([{:ev_rel, :rel_hwheel, 1}]) do
    {:ok, _} = Control.brighten()
  end

  defp handle_events([{:ev_rel, :rel_hwheel, -1}]) do
    {:ok, _} = Control.dim()
  end

  defp handle_events(event) do
    Logger.debug("Unhandled event #{inspect(event)}")
  end
end
