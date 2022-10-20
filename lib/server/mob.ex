defmodule Proto.Server.Mob.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      Proto.Supervisor.server_child_spec(Proto.Server.Mob.Handler, "mob"),
      {
        DynamicSupervisor,
        name: Proto.Server.Mob.MiddlemanSupervisor, strategy: :one_for_one
      }
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
