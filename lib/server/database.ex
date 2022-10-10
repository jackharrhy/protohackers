defmodule Proto.Server.Database do
  require Logger
  import Proto.Utils

  @server_port 4080
  def port, do: @server_port

  def run(port \\ @server_port) do
    run_info('Database', port)
    {:ok, socket} = :gen_udp.open(port, [:binary, active: false])
    serve(socket)
  end

  defp handle(data, state) do
    if String.contains?(data, "=") do
      [key, value] = String.split(data, "=", parts: 2)
      {nil, Map.put(state, key, value)}
    else
      {"#{data}=#{Map.get(state, data)}", state}
    end
  end

  defp serve(socket, state \\ %{}) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, {host, port, "version"}} ->
        :ok =
          :gen_udp.send(socket, host, port, "version=<i>jack arthur null</i>'s kv store 1.0 <3")

        serve(socket, state)

      {:ok, {host, port, data}} ->
        {resp, state} = handle(data, state)
        if resp != nil, do: :ok = :gen_udp.send(socket, host, port, resp)
        serve(socket, state)

      {:error, :closed} ->
        nil
    end
  end
end
