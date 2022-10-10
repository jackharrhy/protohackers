defmodule Proto.Server.Chat.Handler do
  require Logger
  alias Proto.Handler
  alias Proto.Server.Chat.{User, Room, UserSupervisor}
  import Proto.Utils

  @server_port 4070
  def port, do: @server_port

  def run(port \\ @server_port) do
    run_info('Chat', port)
    Handler.setup(port, :line, &introduce/1)
  end

  defp introduce(socket) do
    {socket, name} =
      socket
      |> send_line(
        "Welcome to budgetchat! You are being served by pid #{inspect(self())}, what shall I call you?"
      )
      |> read_line()

    name = String.trim(name)

    if String.match?(name, ~r/^[a-zA-Z0-9]{1,16}$/) do
      clients = Room.clients() |> Enum.map(&elem(&1, 1))
      send_line(socket, "* The room contains: #{Enum.join(clients, ", ")}")
      :inet.setopts(socket, active: true)
      {:ok, pid} = DynamicSupervisor.start_child(UserSupervisor, {User, {socket, name}})
      :gen_tcp.controlling_process(socket, pid)
    else
      send_line(socket, "Invalid name, sorry bud!")
    end
  end
end
