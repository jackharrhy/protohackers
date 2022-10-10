defmodule Proto.Server.Chat.User do
  use GenServer, restart: :temporary
  alias Proto.Server.Chat.Room
  require Logger

  @impl true
  def init({socket, name}) do
    Room.join(self(), name)
    {:ok, {socket, name}}
  end

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def send_message(pid, content), do: GenServer.cast(pid, {:message, content})

  @impl true
  def handle_info({:tcp, socket, data}, {socket, name} = state) do
    Room.message(self(), name, data)
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp_closed, socket}, {socket, name} = state) do
    Room.leave(self(), name)
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:tcp_error, socket, reason}, {socket, name} = state) do
    Room.leave(self(), name)
    {:stop, reason, state}
  end

  @impl true
  def handle_cast({:message, content}, {socket, _name} = state) do
    :gen_tcp.send(socket, content)
    {:noreply, state}
  end
end
