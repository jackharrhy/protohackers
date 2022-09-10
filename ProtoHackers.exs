defmodule EchoServer do
  # https://elixir-lang.org/getting-started/mix-otp/task-and-gen-tcp.html
  require Logger

  def accept(port) do
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    try do
      {:ok, client} = :gen_tcp.accept(socket)
      Task.start_link(fn -> serve(client) end)
    rescue
      e -> Logger.info(Exception.format(:error, e, __STACKTRACE__))
    end

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

EchoServer.accept(4040)
