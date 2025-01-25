defmodule Harbor.MixProject do
  use Mix.Project

  def project do
    [
      app: :harbor,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Harbor.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      { :plug_cowboy, "~> 2.0" },
      { :cachex, "~> 4.0" },
      { :httpoison, "~> 2.0" },
      { :poison, "~> 6.0" }
    ]
  end
end
