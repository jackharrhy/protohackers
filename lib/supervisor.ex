defmodule Proto.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Task.Supervisor, name: Proto.TaskSupervisor},
      {Task, fn -> Proto.Server.Echo.run(4040) end}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
