defmodule Proto.MixProject do
  use Mix.Project

  def project do
    [
      app: :proto,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Proto, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.3"}
    ]
  end
end
