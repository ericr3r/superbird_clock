defmodule SuperbirdClock.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias SuperbirdClock.Display.{Accessory, Buttons, Control}

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
      {HAP, accessory_server("22:33:44:55:66:77")},
      {Control, []}
    ]
  end

  defp children(_target) do
    # Children for all targets except host
    [
      {HAP, accessory_server("11:22:33:44:55:66")},
      {Control, []},
      # {HAP, accessory_server}
      {Buttons, []}
    ]
  end

  defp accessory_server(identifier) do
    %HAP.AccessoryServer{
      name: "Superbird Clock",
      identifier: identifier,
      # Clock accessory type
      accessory_type: 5,
      accessories: [
        %HAP.Accessory{
          name: "Superbird Clock",
          services: [
            %HAP.Services.LightBulb{
              on: {Accessory, :on_off},
              brightness: {Accessory, :brightness},
              name: "Brightness"
            }
          ]
        }
      ]
    }
  end
end
