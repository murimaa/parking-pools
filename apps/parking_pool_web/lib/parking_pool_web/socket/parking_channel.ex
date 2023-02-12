defmodule ParkingPoolWeb.Socket.ParkingChannel do
  use Phoenix.Channel
  require Logger

  @poll_ms 500

  @impl true
  def join("parking_space:" <> parking_space_id, _payload, socket) do
    # if authorized?(payload) do
    Logger.info("User joined channel for #{inspect(parking_space_id)}")
    send(self(), :broadcast_status)
    {:ok, socket}
    # else
    #  {:error, %{reason: "unauthorized"}}
    # end
  end

  def handle_info(:broadcast_status, socket) do
    "parking_space:" <> id = socket.topic
    uid = socket.assigns[:user_id]

    name = String.to_existing_atom(id)
    state = ParkingPool.ParkingSpace.get_state(name)
    state = state
            |> Map.merge(%{id: id})
            |> Map.put(:own, state.reserved_by_uid == uid)
    socket =
      if socket.assigns[:last_status] != state do
        Logger.debug("Broadcasting status for #{name}: #{inspect(state)}. Channel pid: #{inspect(socket.channel_pid)}")
        push(socket, "status", state)
        assign(socket, :last_status, state)
      else
        # No change - no broadcast!
        socket
      end

    # Schedule next status broadcast
    Process.send_after(self(), :broadcast_status, @poll_ms)
    {:noreply, socket}
  end
end
