defmodule Proto.Server.Chat.Room do
  use GenServer
  alias Proto.Server.Chat.User
  require Logger

  @impl true
  def init(_arg \\ nil) do
    {:ok, []}
  end

  def start_link(_default) do
    GenServer.start_link(__MODULE__, [], name: :chat_room)
  end

  defp message_clients(clients, message, exclude_pid) do
    for {pid, _name} <- clients do
      if pid != exclude_pid do
        User.send_message(pid, String.trim(message) <> "\n")
      end
    end
  end

  def message(pid, name, content), do: GenServer.cast(:chat_room, {:message, pid, name, content})
  def join(pid, name), do: GenServer.cast(:chat_room, {:join, pid, name})
  def leave(pid, name), do: GenServer.cast(:chat_room, {:leave, pid, name})
  def clients, do: GenServer.call(:chat_room, :clients)

  @impl true
  def handle_cast({:message, pid, name, content}, clients) do
    message_clients(clients, "[#{name}] #{content}", pid)
    {:noreply, clients}
  end

  @impl true
  def handle_cast({:join, pid, name}, clients) do
    message_clients(clients, "* #{name} has entered the room", pid)
    {:noreply, [{pid, name} | clients]}
  end

  @impl true
  def handle_cast({:leave, pid, name}, clients) do
    message_clients(clients, "* #{name} has left", pid)
    {:noreply, clients |> Enum.filter(fn {c_pid, _name} -> c_pid != pid end)}
  end

  @impl true
  def handle_call(:clients, _from, clients) do
    {:reply, clients, clients}
  end
end
