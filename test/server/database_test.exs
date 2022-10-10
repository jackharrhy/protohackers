defmodule ProtoTest.Server.Database do
  use ExUnit.Case, async: false
  doctest Proto.Server.Database

  @starting_port 11000

  def init_socket(port) do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_udp.open(port, opts)
    socket
  end

  def close_socket(socket) do
    :ok = :gen_udp.close(socket)
  end

  defp db_send(socket, data) do
    :ok = :gen_udp.send(socket, {127, 0, 0, 1}, Proto.Server.Database.port(), data)
    socket
  end

  defp get(socket, key) do
    {:ok, {_host, _port, data}} = db_send(socket, key) |> :gen_udp.recv(0)
    {socket, data}
  end

  defp set(socket, key, data), do: db_send(socket, "#{key}=#{data}")

  defp assert_data({socket, data}, expected) do
    assert data == expected
    socket
  end

  defp restart_db do
    Supervisor.restart_child(Proto.Supervisor, "database")
  end

  test "sends sets value correctly" do
    restart_db()

    init_socket(@starting_port)
    |> set("a", "2")
    |> get("a")
    |> assert_data("a=2")
    |> close_socket()
  end

  test "more complex examples" do
    restart_db()

    init_socket(@starting_port)
    |> set("foo", "bar")
    |> get("foo")
    |> assert_data("foo=bar")
    |> set("foo", "bar=baz")
    |> get("foo")
    |> assert_data("foo=bar=baz")
    |> set("foo", "")
    |> get("foo")
    |> assert_data("foo=")
    |> set("foo", "==")
    |> get("foo")
    |> assert_data("foo===")
    |> set("", "foo")
    |> get("")
    |> assert_data("=foo")
    |> close_socket()
  end

  test "responds with just key='nothing' for nonexistent key" do
    restart_db()

    init_socket(@starting_port)
    |> get("a")
    |> assert_data("a=")
    |> close_socket()
  end

  test "responds with special version case" do
    restart_db()

    init_socket(@starting_port)
    |> get("version")
    |> assert_data("version=<i>jack arthur null</i>'s kv store 1.0 <3")
    |> close_socket()
  end
end
