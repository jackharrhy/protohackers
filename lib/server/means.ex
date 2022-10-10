defmodule Proto.Server.Means do
  require Logger
  alias Proto.Handler
  import Proto.Utils

  @server_port 4060
  def port, do: @server_port

  def run(port \\ @server_port) do
    run_info('Means', port)
    Handler.setup(port, :raw, &serve/1)
  end

  defp handle(?I, timestamp, price, records) do
    entry = %{:timestamp => timestamp, :price => price}
    {:input, [entry | records]}
  end

  defp handle(?Q, mintime, maxtime, records) do
    prices =
      if mintime > maxtime do
        []
      else
        records
        |> Enum.filter(&(&1[:timestamp] >= mintime and &1[:timestamp] <= maxtime))
        |> Enum.map(& &1[:price])
      end

    count = Enum.count(prices)

    mean =
      if count == 0 do
        0
      else
        round(Enum.sum(prices) / Enum.count(prices))
      end

    {:query, <<mean::32>>}
  end

  defp parse_packet(<<arg1, arg2::signed-size(32), arg3::signed-size(32)>>) do
    {arg1, arg2, arg3}
  end

  defp serve(socket, records \\ []) do
    case :gen_tcp.recv(socket, 9) do
      {:ok, packet} ->
        try do
          {arg1, arg2, arg3} = parse_packet(packet)

          case handle(arg1, arg2, arg3, records) do
            {:input, records} ->
              serve(socket, records)

            {:query, mean} ->
              :ok = :gen_tcp.send(socket, mean)
              serve(socket, records)
          end
        rescue
          e ->
            {:error, e}
        end

      {:error, e} ->
        {:error, e}
    end
  end
end
