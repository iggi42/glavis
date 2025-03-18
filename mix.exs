defmodule Glavis.MixProject do
  use Mix.Project

  def project do
    [
      app: :glavis,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Glavis.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.16"},

      # for fa&fo (fucking around and finding out)
      {:plug_cowboy, "~> 2.0"},
      {:open_pgp, "~> 0.5.1"}
    ]
  end
end
