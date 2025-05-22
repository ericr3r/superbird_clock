defmodule SuperbirdClock.Scene.Waiting do
  @moduledoc """
  This is a minimal scene with some text.
  """
  use Scenic.Scene

  import Scenic.Primitives

  alias Scenic.Graph

  @font_size 60

  def init(scene, _param, _opts) do
    {vp_width, vp_height} = scene.viewport.size

    graph =
      Graph.build(font: :roboto, font_size: @font_size, text_align: :center)
      |> text("Waiting on Time",
        translate: {vp_width / 2, vp_height / 2},
        styles: [font: :roboto, font_size: @font_size, text_align: :right, fill: :dim_grey]
      )

    {:ok, push_graph(scene, graph)}
  end
end
