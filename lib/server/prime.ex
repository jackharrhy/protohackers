defmodule Proto.Server.Prime do
  require Logger

  @server_port 4050
  def port, do: @server_port

  def run(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])
    Logger.info("Prime Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Proto.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp is_prime(n) when n <= 1 do
    false
  end

  defp is_prime(n) do
    Enum.find(2..(trunc(:math.sqrt(n)) + 1), fn x -> rem(n, x) == 0 end) == nil
  end

  defp handle_request(%{"method" => "isPrime", "number" => number}) when is_number(number) do
    %{"method" => "isPrime", "prime" => is_prime(number)}
  end

  defp serve(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        req = Jason.decode!(data)
        resp = handle_request(req)
        :ok = :gen_tcp.send(socket, "#{Jason.encode!(resp)}\n")
        serve(socket)

      {:error, :closed} ->
        nil
    end
  end
end
