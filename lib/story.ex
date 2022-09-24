defmodule Proto.Story do
  require Logger

  use GenServer

  @impl true
  def init(state) do
    {:ok, state}
  end

  def start_link(_default) do
    GenServer.start_link(__MODULE__, [], name: :proto_story)
  end

  def event(payload) do
    GenServer.cast(:proto_story, {:event, payload})
  end

  def dump do
    GenServer.call(:proto_story, :dump)
  end

  def dump_to_file(path) do
    GenServer.cast(:proto_story, {:dump, path})
  end

  @impl true
  def handle_cast({:event, payload}, state) do
    # TODO add event to state
    # IO.inspect(payload)
    {:noreply, state}
  end

  @impl true
  def handle_call(:dump, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:dump, path}, state) do
    {:reply, state, state}
  end
end
