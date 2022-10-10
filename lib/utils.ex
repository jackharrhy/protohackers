defmodule Proto.Utils do
  require Logger

  def run_info(name, port) do
    Logger.info("#{name} starting on port #{port}")
  end

  def info(socket, message) do
    Logger.info("#{__MODULE__} #{inspect(socket)}: #{message}")
  end

  def send_line(socket, line) do
    :ok = :gen_tcp.send(socket, "#{line}\n")
    socket
  end

  def read_line(socket) do
    {:ok, resp} = :gen_tcp.recv(socket, 0)
    {socket, resp}
  end
end
