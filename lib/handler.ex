defmodule Proto.Handler do
  def setup(port, packet, child_handler) do
    create_listener(port, packet) |> loop_acceptor(child_handler)
  end

  def create_listener(port, packet) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: packet, active: false, reuseaddr: true])

    socket
  end

  def loop_acceptor(socket, child_handler) do
    {:ok, client} = :gen_tcp.accept(socket)

    {:ok, pid} =
      Task.Supervisor.start_child(Proto.TaskSupervisor, fn ->
        child_handler.(client)
      end)

    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket, child_handler)
  end
end
