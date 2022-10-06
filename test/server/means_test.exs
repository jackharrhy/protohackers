defmodule ProtoTest.Server.Means do
  use ExUnit.Case, async: true
  doctest Proto.Server.Means

  def init_socket() do
    opts = [:binary, active: false, packet: :raw]
    {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, Proto.Server.Means.port(), opts)
    socket
  end

  def close_socket(socket) do
    :ok = :gen_tcp.close(socket)
  end

  def input(timestamp, price), do: <<?I>> <> <<timestamp::32>> <> <<price::32>>

  def send_input(socket, timestamp, price) do
    :ok = :gen_tcp.send(socket, input(timestamp, price))
    socket
  end

  def query(mintime, maxtime), do: <<?Q>> <> <<mintime::32>> <> <<maxtime::32>>

  def send_query(socket, mintime, maxtime) do
    :ok = :gen_tcp.send(socket, query(mintime, maxtime))
    {:ok, <<mean::32>>} = :gen_tcp.recv(socket, 4)
    mean
  end

  test "inputs data, calculates mean for entire timeframe" do
    socket =
      init_socket()
      |> send_input(0, 50)
      |> send_input(1, 60)
      |> send_input(2, 80)
      |> send_input(3, 100)

    mean = send_query(socket, 0, 3)
    assert mean == 73

    socket |> close_socket()
  end

  test "inputs data, calculates mean for limited timeframe" do
    socket =
      init_socket()
      |> send_input(10, 40)
      |> send_input(12, 50)
      |> send_input(20, 120)
      |> send_input(21, 150)
      |> send_input(22, 130)
      |> send_input(45, 10)
      |> send_input(46, 5)

    mean = send_query(socket, 20, 22)
    assert mean == 133

    socket |> close_socket()
  end

  test "inputs data out of order, calculates mean for multiple timeframe" do
    socket =
      init_socket()
      |> send_input(10, 40)
      |> send_input(20, 120)
      |> send_input(46, 5)
      |> send_input(22, 130)
      |> send_input(21, 150)
      |> send_input(12, 50)
      |> send_input(45, 10)

    assert 133 == send_query(socket, 20, 22)
    assert 72 == send_query(socket, 0, 100)
    assert 74 == send_query(socket, 21, 100)
    assert 5 == send_query(socket, 46, 46)
    assert 0 == send_query(socket, 500, 1000)
    assert 0 == send_query(socket, 20, 10)

    socket |> close_socket()
  end
end
