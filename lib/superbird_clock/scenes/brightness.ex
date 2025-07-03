defmodule SuperbirdClock.Scene.Brightness do
  @moduledoc """
  This is a minimal scene with some text.
  """
  use Scenic.Scene

  import Scenic.Primitives

  alias Scenic.Graph

  @font_size 80

  defmodule State do
    defstruct brightness: 100
  end

  def init(scene, _param, _opts) do
    {vp_width, vp_height} = scene.viewport.size
    state = %State{brightness: 100}

    graph =
      Graph.build(font: :roboto, font_size: @font_size, text_align: :center)
      |> text("#{state.brightness} %",
        id: :brightness_text,
        translate: {vp_width / 2, vp_height / 2},
        styles: [font: :roboto, font_size: @font_size, text_align: :center, fill: :dim_grey]
      )

    # Store the initial graph in assigns
    scene =
      scene
      |> assign(:state, state)
      |> assign(:graph, graph)
      |> push_graph(graph)

    # Register the process with its module name
    init_and_register()

    {:ok, scene}
  end

  def set_brightness(scene, brightness)
      when is_integer(brightness) and brightness >= 0 and brightness <= 100 do
    # Get the current state
    state = scene.assigns.state

    # Update the state with the new brightness
    updated_state = %State{state | brightness: brightness}

    # Get the current graph from assigns and update it
    graph =
      scene.assigns.graph
      |> Graph.modify(:brightness_text, &text(&1, "#{brightness} %"))

    # Update the scene with the new state and graph
    scene =
      scene
      |> assign(:state, updated_state)
      |> assign(:graph, graph)
      |> push_graph(graph)

    scene
  end

  # Helper function to get the current brightness value
  def get_brightness do
    if pid = Process.whereis(__MODULE__) do
      GenServer.call(pid, :get_brightness)
    else
      nil
    end
  end

  # Helper function to create a scene update
  def set_brightness(brightness) do
    if Process.whereis(__MODULE__) do
      send(Process.whereis(__MODULE__), {:set_brightness, brightness})
    end
  end

  # Register this module with its own name during initialization
  def init_and_register(name \\ __MODULE__) do
    Process.register(self(), name)
  end

  # Handle info callback for brightness updates
  def handle_info({:set_brightness, brightness}, scene) do
    updated_scene = set_brightness(scene, brightness)
    {:noreply, updated_scene}
  end

  # Handle call callback for getting brightness
  def handle_call(:get_brightness, _from, scene) do
    brightness = scene.assigns.state.brightness
    {:reply, brightness, scene}
  end
end
