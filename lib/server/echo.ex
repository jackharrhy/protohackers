defmodule Proto.Server.Echo do
  require Logger
  alias Proto.Handler
  import Proto.Utils

  @server_port 4040
  def port, do: @server_port

  def run(port \\ @server_port) do
    run_info('Echo', port)
    Handler.setup(port, :raw, &serve/1)
  end

  defp serve(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        :ok = :gen_tcp.send(socket, data)
        serve(socket)

      {:error, :closed} ->
        nil
    end
  end
end
