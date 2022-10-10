defmodule Proto do
  use Application

  @impl true
  def start(_type, _args) do
    Proto.Supervisor.start_link(name: Proto.Supervisor)
  end
end
