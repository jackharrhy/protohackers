defmodule Proto.Server.Prime do
  require Logger

  @server_port 4050
  def port, do: @server_port

  def info(socket, message) do
    Logger.info("Prime #{inspect(socket)}: #{message}")
  end

  def run(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    info(socket, "accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Proto.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    info(socket, "accept #{inspect(client)}, managed by #{inspect(pid)}")
    loop_acceptor(socket)
  end

  defp is_prime?(n) when n in [2, 3], do: true

  defp is_prime?(n) when n > 1 do
    floored_sqrt =
      :math.sqrt(n)
      |> Float.floor()
      |> round

    !Enum.any?(2..floored_sqrt, &(rem(n, &1) == 0))
  end

  defp is_prime?(_n) do
    false
  end

  defp handle_request(%{"method" => "isPrime", "number" => number}) when is_number(number) do
    %{"method" => "isPrime", "prime" => is_prime?(number)}
  end

  defp serve(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        info(socket, "recv #{data}")
        req = Jason.decode!(data)
        info(socket, "req #{inspect(req)}")
        resp = handle_request(req)
        info(socket, "resp #{inspect(resp)}")
        :ok = :gen_tcp.send(socket, "#{Jason.encode!(resp)}\n")
        serve(socket)

      {:error, :closed} ->
        nil
    end
  end
end
