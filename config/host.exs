import Config

# Add configuration that is only needed when running on the host here.

config :nerves_runtime,
  kv_backend:
    {Nerves.Runtime.KVBackend.InMemory,
     contents: %{
       # The KV store on Nerves systems is typically read from UBoot-env, but
       # this allows us to use a pre-populated InMemory store when running on
       # host for development and testing.
       #
       # https://hexdocs.pm/nerves_runtime/readme.html#using-nerves_runtime-in-tests
       # https://hexdocs.pm/nerves_runtime/readme.html#nerves-system-and-firmware-metadata

       "nerves_fw_active" => "a",
       "a.nerves_fw_architecture" => "generic",
       "a.nerves_fw_description" => "N/A",
       "a.nerves_fw_platform" => "host",
       "a.nerves_fw_version" => "0.0.0"
     }}

config :superbird_clock, :viewport,
  name: :main_viewport,
  size: {400, 800},
  default_scene: SuperbirdClock.Scene.Digital,
  drivers: [
    [
      module: Scenic.Driver.Local,
      window: [title: "SuperbirdClock", resizeable: true],
      on_close: :stop_system
    ]
  ],
  opts: [
    rotate: :math.pi() / 2,
    pin: {200, 120},
    translate: {200, 120}
  ]
