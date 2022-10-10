defmodule Proto.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def server_child_spec(module, id) do
    Supervisor.child_spec({Task, fn -> module.run() end}, id: id)
  end

  @impl true
  def init(:ok) do
    children = [
      {Task.Supervisor, name: Proto.TaskSupervisor},
      server_child_spec(Proto.Server.Echo, "echo"),
      server_child_spec(Proto.Server.Prime, "prime"),
      server_child_spec(Proto.Server.Means, "means"),
      {Proto.Server.Chat.Supervisor, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
