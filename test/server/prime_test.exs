defmodule ProtoTest.Server.Prime do
  use ExUnit.Case, async: true
  doctest Proto.Server.Prime

  def init_socket() do
    opts = [:binary, active: false, packet: :raw]
    {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, Proto.Server.Prime.port(), opts)
    socket
  end

  def close_socket(socket) do
    :ok = :gen_tcp.close(socket)
  end

  def send_assert_resp(socket, data, expected_resp) do
    :ok = :gen_tcp.send(socket, data)
    {:ok, resp} = :gen_tcp.recv(socket, 0)
    assert resp == expected_resp
    socket
  end

  test "handles valid input, and non prime numbers as false" do
    [123, 500, 6, 54]
    |> Enum.map(fn number ->
      init_socket()
      |> send_assert_resp(
        Jason.encode!(%{"method" => "isPrime", "number" => number}),
        "#{Jason.encode!(%{"method" => "isPrime", "prime" => false})}\n"
      )
      |> close_socket()
    end)
  end

  test "handles valid input, and prime numbers as true" do
    [7, 53, 97, 199, 911]
    |> Enum.map(fn number ->
      init_socket()
      |> send_assert_resp(
        Jason.encode!(%{"method" => "isPrime", "number" => number}),
        "#{Jason.encode!(%{"method" => "isPrime", "prime" => true})}\n"
      )
      |> close_socket()
    end)
  end
end
