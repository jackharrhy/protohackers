defmodule Proto.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Task.Supervisor, name: Proto.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> Proto.Server.Echo.run(Proto.Server.Echo.port()) end},
        id: "echo"
      ),
      Supervisor.child_spec({Task, fn -> Proto.Server.Prime.run(Proto.Server.Prime.port()) end},
        id: "prime"
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
