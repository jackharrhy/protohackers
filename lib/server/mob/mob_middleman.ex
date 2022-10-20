defmodule Proto.Server.Mob.Middleman do
  use GenServer, restart: :temporary
  require Logger

  @impl true
  def init(client_socket) do
    opts = [:binary, active: true, packet: :line]
    {:ok, outbound_socket} = :gen_tcp.connect({206, 189, 113, 124}, 16963, opts)
    {:ok, {client_socket, outbound_socket}}
  end

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def is_address(data) do
    data = String.trim(data)
    len = String.length(data)

    starts_with_7 = String.starts_with?(data, "7")
    at_least_26 = len >= 26
    at_most_36 = len <= 35
    alpha_numeric = Regex.match?(~r/^[a-zA-Z0-9]*$/, data)

    starts_with_7 && at_least_26 && at_most_36 && alpha_numeric
  end

  def convert_address(data) do
    if is_address(data) do
      "7YWHMfk9JZe0LM0g1ZauHuiSxhI"
    else
      data
    end
  end

  def convert_addresses(data) do
    converted =
      String.split(data, " ")
      |> Enum.map(&convert_address/1)
      |> Enum.join(" ")
      |> String.trim()

    converted <> "\n"
  end

  @impl true
  def handle_info({:tcp, client_socket, data}, {client_socket, outbound_socket} = state) do
    :ok = :gen_tcp.send(outbound_socket, convert_addresses(data))
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp, outbound_socket, data}, {client_socket, outbound_socket} = state) do
    :ok = :gen_tcp.send(client_socket, convert_addresses(data))
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:tcp_error, _socket, reason}, state) do
    {:stop, reason, state}
  end
end
