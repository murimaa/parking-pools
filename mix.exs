defmodule MixProject do
  use Mix.Project

  def project do
    [
      app: :parking_pool,
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: [
        parking_pool_full: [
          applications: [
            parking_pool: :permanent,
            parking_pool_web: :permanent
          ]
        ]
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    []
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      #    setup: ["deps.get", "assets.setup"],
      #    "assets.setup": ["tailwind.install --if-missing", "cmd --cd assets pwd", "cmd --cd assets npm install"],
      #    "assets.deploy": ["tailwind default --minify", "cmd --cd assets node build.js --deploy", "phx.digest"]
    ]
  end
end
