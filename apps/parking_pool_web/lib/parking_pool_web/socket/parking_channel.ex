defmodule ParkingPoolWeb.Socket.ParkingChannel do
  use Phoenix.Channel
  require Logger

  @periodic_update_every_ms 30_000

  @impl true
  def join("parking_space:" <> parking_space_id, _payload, socket) do
    # if authorized?(payload) do
    Logger.info("User joined channel for #{inspect(parking_space_id)}")

    Phoenix.PubSub.subscribe(:parking_pool_pubsub, "parking_space:#{parking_space_id}")

    # Get initial state
    initial_state = ParkingPool.ParkingSpace.get_state(String.to_existing_atom(parking_space_id))
    # Mimic a state_change message from the process to trigger broadcast
    send(self(), {:state_change, initial_state})

    # Schedule periodic update in case a websocket message is missed by frontend
    Process.send_after(self(), :periodic_update, @periodic_update_every_ms)

    {:ok, socket}
    # else
    #  {:error, %{reason: "unauthorized"}}
    # end
  end

  # Do periodic updates in case a websocket message is missed by frontend
  def handle_info(:periodic_update, socket) do
    "parking_space:" <> id = socket.topic

    # Get state
    state = ParkingPool.ParkingSpace.get_state(String.to_existing_atom(id))
    # Mimic a state_change message from the process to trigger broadcast
    send(self(), {:state_change, state})

    # Schedule periodic update in case a websocket message is missed by front end
    Process.send_after(self(), :periodic_update, @periodic_update_every_ms)

    {:noreply, socket}
  end

  # We get this from ParkingPool.ParkingSpace when there
  # is a change in the state of the parking space
  # --> broadcast to channel
  def handle_info({:state_change, state}, socket) do
    do_broadcast_state(state, socket)
    {:noreply, socket}
  end

  defp do_broadcast_state(state, socket) do
    "parking_space:" <> id = socket.topic
    uid = socket.assigns[:user_id]

    state = state
            |> Map.merge(%{id: id})
            |> Map.put(:own, state.reserved_by_uid == uid)

    Logger.debug("Broadcasting status for #{id}: #{inspect(state)}. Channel pid: #{inspect(socket.channel_pid)}")
    push(socket, "status", state)
  end
end
