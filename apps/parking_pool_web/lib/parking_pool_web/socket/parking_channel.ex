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

    name = String.to_existing_atom(id)
    reserved = ParkingPool.ParkingSpace.reserved?(name)

    status = %{reserved: reserved}

    socket =
      if socket.assigns[:last_status] != status do
        Logger.debug("Broadcasting status for #{name}: #{inspect(status)}. Pid: #{inspect(self())}, Channel pid: #{inspect(socket.channel_pid)}")
        push(socket, "status", status)
        assign(socket, :last_status, status)
      else
        # No change - no broadcast!
        socket
      end

    # Schedule next status broadcast
    Process.send_after(self(), :broadcast_status, @poll_ms)
    {:noreply, socket}
  end
end
