defmodule Proto.Server.Mob.Handler do
  require Logger
  alias Proto.Handler
  import Proto.Utils
  alias Proto.Server.Mob.{Middleman, MiddlemanSupervisor}

  @server_port 4090
  def port, do: @server_port

  def run(port \\ @server_port) do
    run_info('Mob', port)
    Handler.setup(port, :line, &setup/1)
  end

  defp setup(socket) do
    :inet.setopts(socket, active: true)
    {:ok, pid} = DynamicSupervisor.start_child(MiddlemanSupervisor, {Middleman, socket})
    :gen_tcp.controlling_process(socket, pid)
  end
end
