defmodule Proto.Server.Prime do
  require Logger
  alias Proto.Handler
  import Proto.Utils

  @server_port 4050
  def port, do: @server_port

  def run(port \\ @server_port) do
    run_info('Prime', port)
    Handler.setup(port, :raw, &serve/1)
  end

  defp is_prime?(n) when is_float(n), do: false

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

  defp chunk(socket, message \\ "") do
    case :gen_tcp.recv(socket, 1) do
      {:ok, data} ->
        if data == "\n" do
          {:ok, message}
        else
          chunk(socket, message <> data)
        end

      {:error, e} ->
        {:error, e}
    end
  end

  def handle_line(socket, line) do
    req = Jason.decode!(line)
    resp = handle_request(req)
    :ok = :gen_tcp.send(socket, "#{Jason.encode!(resp)}\n")
    socket
  end

  defp serve(socket) do
    case chunk(socket) do
      {:ok, line} ->
        handle_line(socket, line) |> serve

      {:error, e} ->
        {:error, e}
    end
  end
end
