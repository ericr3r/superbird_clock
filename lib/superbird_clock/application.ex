defmodule SuperbirdClock.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias SuperbirdClock.Control.Buttons

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: SuperbirdClock.Supervisor]

    scenic_viewport_config = Application.get_env(:superbird_clock, :viewport)

    children =
      [
        # Children for all targets
        # Starts a worker by calling: SuperbirdClock.Worker.start_link(arg)
        # {SuperbirdClock.Worker, arg},
        {Scenic, [scenic_viewport_config]}
      ] ++ children(Nerves.Runtime.mix_target())

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  defp children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: SuperbirdClock.Worker.start_link(arg)
      # {SuperbirdClock.Worker, arg},
    ]
  end

  defp children(_target) do
    # accessory_server = %HAP.AccessoryServer{
    #   name: "Superbird Clock",
    #   identifier: "11:22:33:44:55:66",
    #   accessory_type: 5,  # Clock accessory type
    #   accessories: [
    #     %HAP.Accessory{
    #       name: "Superbird Clock",
    #       services: [
    #         %HAP.Services.LightBulb{
    #           on: {Screen, :on_off },
    #           # brightness: {Screen},
    #           name: "Display Brightness"
    #         }
    #       ]
    #     }
    #   ]
    # }

    # Children for all targets except host
    # Starts a worker by calling: SuperbirdClock.Worker.start_link(arg)
    # {SuperbirdClock.Worker, arg},
    # {}
    [
      # {HAP, accessory_server}
      {Buttons, []}
    ]
  end
end
