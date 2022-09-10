defmodule Proto.Server.Echo do
  require Logger

  @server_port 4040
  def port, do: @server_port

  def run(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])
    Logger.info("Echo Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Proto.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    Logger.info("#{inspect(socket)} accept: #{inspect(client)}, managed by #{inspect(pid)}")
    loop_acceptor(socket)
  end

  defp serve(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        Logger.info("#{inspect(socket)}: recv #{data}, sending back")
        :ok = :gen_tcp.send(socket, data)
        serve(socket)

      {:error, :closed} ->
        Logger.info("#{inspect(socket)} closed")
        nil
    end
  end
end
