defmodule Proto.Supervisor.Chat do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      Proto.Supervisor.server_child_spec(Proto.Server.Chat.Handler, "chat"),
      {
        DynamicSupervisor,
        name: Proto.Server.Chat.UserSupervisor, strategy: :one_for_one
      },
      Proto.Server.Chat.Room
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
