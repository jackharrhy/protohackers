defmodule ProtoTest.Supervisor.Chat do
  use ExUnit.Case, async: false
  doctest Proto.Supervisor.Chat

  def init_socket() do
    opts = [:binary, active: false, packet: :line]
    {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, Proto.Server.Chat.Handler.port(), opts)
    socket
  end

  def close_socket(socket) do
    :ok = :gen_tcp.close(socket)
  end

  def send_line(socket, line) do
    :ok = :gen_tcp.send(socket, "#{line}\n")
    socket
  end

  def read_line(socket) do
    {:ok, resp} = :gen_tcp.recv(socket, 0)
    {socket, resp}
  end

  defp connect_client(name) do
    init_socket()
    |> read_line()
    |> elem(0)
    |> send_line(name)
    |> read_line()
  end

  test "sends hello message" do
    {socket, resp} = init_socket() |> read_line()

    assert String.starts_with?(resp, "Welcome to budgetchat!")

    socket
    |> send_line("joe")
    |> close_socket()
  end

  test "responds with clients" do
    {_, resp} = connect_client("joe")
    assert resp == "* The room contains: \n"

    {_, resp} = connect_client("bob")
    assert resp == "* The room contains: joe\n"

    {_, resp} = connect_client("james")

    assert resp == "* The room contains: bob, joe\n"
  end

  test "rejects invalid usernames" do
    name = "name with spaces and ^"

    {socket, resp} =
      init_socket()
      |> read_line()
      |> elem(0)
      |> send_line(name)
      |> read_line()

    assert String.starts_with?(resp, "Invalid name")

    socket |> close_socket()
  end
end
