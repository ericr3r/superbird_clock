defmodule SuperbirdClock.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

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
    [
      # Children for all targets except host
      # Starts a worker by calling: SuperbirdClock.Worker.start_link(arg)
      # {SuperbirdClock.Worker, arg},
    ]
  end
end
