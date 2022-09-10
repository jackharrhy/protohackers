defmodule ProtoTest.Server.Prime do
  use ExUnit.Case, async: false
  doctest Proto.Server.Prime

  def init_socket() do
    opts = [:binary, active: false, packet: :line]
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
    tasks =
      [123, 500, 6, 54, 2.2, 123.123187923]
      |> Enum.map(fn number ->
        Task.async(fn ->
          init_socket()
          |> send_assert_resp(
            "#{Jason.encode!(%{"method" => "isPrime", "number" => number})}\n",
            "#{Jason.encode!(%{"method" => "isPrime", "prime" => false})}\n"
          )
          |> close_socket()
        end)
      end)

    tasks |> Enum.map(&Task.await(&1))
  end

  test "handles valid input, and prime numbers as true" do
    tasks =
      [2, 7, 53, 97, 199, 911]
      |> Enum.map(fn number ->
        Task.async(fn ->
          init_socket()
          |> send_assert_resp(
            "#{Jason.encode!(%{"method" => "isPrime", "number" => number})}\n",
            "#{Jason.encode!(%{"method" => "isPrime", "prime" => true})}\n"
          )
          |> close_socket()
        end)
      end)

    tasks |> Enum.map(&Task.await(&1))
  end

  test "handles valid input, with long garbage" do
    string =
      "Did you ever hear the tragedy of Darth Plagueis The Wise? I thought not. It’s not a story the Jedi would tell you. It’s a Sith legend. Darth Plagueis was a Dark Lord of the Sith, so powerful and so wise he could use the Force to influence the midichlorians to create life… He had such a knowledge of the dark side that he could even keep the ones he cared about from dying. The dark side of the Force is a pathway to many abilities some consider to be unnatural. He became so powerful… the only thing he was afraid of was losing his power, which eventually, of course, he did. Unfortunately, he taught his apprentice everything he knew, then his apprentice killed him in his sleep. Ironic. He could save others from death, but not himself."

    long_string = String.duplicate(string, 10)

    init_socket()
    |> send_assert_resp(
      "#{Jason.encode!(%{"method" => "isPrime", "number" => 7, "garbage" => long_string})}\n",
      "#{Jason.encode!(%{"method" => "isPrime", "prime" => true})}\n"
    )
    |> close_socket()
  end
end
