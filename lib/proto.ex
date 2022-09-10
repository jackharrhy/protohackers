defmodule Proto do
  use Application

  @impl true
  def start(_type, _args) do
    Proto.Supervisor.start_link(name: Proto.Supervisor)
  end

  def hello do
    :world
  end
end

defmodule Proto.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Task.Supervisor, name: Proto.TaskSupervisor},
      {Task, fn -> Proto.EchoServer.run(4040) end}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Proto.EchoServer do
  # https://elixir-lang.org/getting-started/mix-otp/task-and-gen-tcp.html
  require Logger

  def run(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Proto.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
