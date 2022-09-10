defmodule ProtoTest.Server.Echo do
  use ExUnit.Case
  doctest Proto.Server.Echo

  def init_socket() do
    opts = [:binary, active: false, packet: :raw]
    {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, 4040, opts)
    socket
  end

  def close_socket(socket) do
    :ok = :gen_tcp.close(socket)
  end

  def send_and_recv(socket, data) do
    :ok = :gen_tcp.send(socket, data)
    {:ok, ^data} = :gen_tcp.recv(socket, 0)
    socket
  end

  test "handles one client correctly" do
    init_socket()
    |> send_and_recv("some data")
    |> send_and_recv("🗻")
    |> send_and_recv("123")
    |> close_socket()
  end

  test "handles five sporadic clients correctly" do
    tasks =
      0..5
      |> Enum.map(fn _x ->
        :timer.sleep(Enum.random(0..100))

        Task.async(fn ->
          :timer.sleep(Enum.random(0..100))
          socket = init_socket()
          :timer.sleep(Enum.random(0..100))
          socket = send_and_recv(socket, "what")
          :timer.sleep(Enum.random(0..100))
          socket = send_and_recv(socket, "a")
          :timer.sleep(Enum.random(0..100))
          socket = send_and_recv(socket, "plonker")
        end)
      end)

    :timer.sleep(Enum.random(0..100))

    tasks |> Enum.map(&Task.await(&1))
  end
end
