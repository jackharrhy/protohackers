defmodule Proto.Server.Means do
  require Logger

  @server_port 4060
  def port, do: @server_port

  def info(socket, message) do
    Logger.info("Means #{inspect(socket)}: #{message}")
  end

  def run(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])
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

  defp handle(socket, "I" <> <<timestamp::32>> <> <<price::32>>, records) do
    info(socket, "input: #{timestamp} -> #{price}")

    entry = %{:timestamp => timestamp, :price => price}
    {:input, [entry | records]}
  end

  defp handle(socket, "Q" <> <<mintime::32>> <> <<maxtime::32>>, records) do
    info(socket, "query: #{mintime}-#{maxtime}")

    prices =
      records
      |> Enum.filter(&(&1[:timestamp] >= mintime and &1[:timestamp] <= maxtime))
      |> Enum.map(& &1[:price])

    mean = round(Enum.sum(prices) / Enum.count(prices))

    info(socket, "query response: #{mean}")
    {:query, <<mean::32>>}
  end

  defp serve(socket, records \\ []) do
    case :gen_tcp.recv(socket, 9) do
      {:ok, packet} ->
        info(socket, "packet: #{inspect(packet)}")

        case handle(socket, packet, records) do
          {:input, records} ->
            serve(socket, records)

          {:query, mean} ->
            :ok = :gen_tcp.send(socket, mean)
            serve(socket, records)
        end

      {:error, e} ->
        {:error, e}
    end

    serve(socket)
  end
end