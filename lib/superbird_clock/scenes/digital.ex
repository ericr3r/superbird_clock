defmodule SuperbirdClock.Scene.Digital do
  @moduledoc """
  This is a minimal scene with some text.
  """
  use Scenic.Scene

  alias Scenic.Graph

  @font_size 140

  def init(scene, _param, _opts) do
    {vp_width, vp_height} = scene.viewport.size

    graph =
      Graph.build(font: :roboto, font_size: @font_size, text_align: :center)
      |> Scenic.Clock.Components.digital_clock(
        translate: {vp_width / 4, vp_height / 2},
        styles: [font: :roboto, font_size: @font_size, text_align: :left, fill: :dim_grey]
      )

    {:ok, push_graph(scene, graph)}
  end
end
