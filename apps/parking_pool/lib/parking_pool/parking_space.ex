defmodule ParkingPool.ParkingSpace do
  use GenServer
  alias __MODULE__
  require Logger

  defstruct [:id, :display_name, :reserved_by_name, :reserved_by_uid, :reserve_timer_ref]

  @default_reserve_time Application.compile_env(:parking_pool, :reservation_time)

  def start_link(id, display_name) do
    GenServer.start_link(__MODULE__, {id, display_name}, name: id)
  end

  def init({id, display_name}) do
    Logger.info("Initializing parking space #{display_name}")
    {:ok, %ParkingSpace{id: id, display_name: display_name}}
  end

  # Public API
  def reserve(spot, uid, display_name), do: GenServer.call(spot, {:reserve, uid, display_name})
  def free(spot, uid), do: GenServer.call(spot, {:free, uid})
  def reserved?(spot), do: GenServer.call(spot, :reserved?)
  def get_state(spot), do: GenServer.call(spot, :get_state)


  # Internal

  def handle_call(:reserved?, _from, state = %ParkingSpace{reserved_by_uid: nil}), do: {:reply, false, state}

  def handle_call(:reserved?, _from, state), do: {:reply, true, state}

  def handle_call(:get_state, _from, state = %ParkingSpace{reserved_by_uid: uid, reserved_by_name: name}) do
    status = get_broadcast_status(state)
    {:reply, status, state}
  end

  def handle_call({:reserve, uid, name}, _from, state = %ParkingSpace{reserved_by_uid: nil}) do
    Logger.info("Reserving parking spot for: #{uid}, #{name}")

    {:reply, :ok, update_reservation(state, uid, name)}
  end

  def handle_call({:reserve, _display_name, _uid}, _from, state) do
    {:reply, :already_reserved, state}
  end

  def handle_call({:free, _uid}, _from, state = %ParkingSpace{reserved_by_uid: nil}) do
    {:reply, {:error, :not_reserved}, state}
  end

  # Freeing own space - uid matches with reserved_by_uid
  def handle_call({:free, uid}, _from, state = %ParkingSpace{reserved_by_uid: uid}) do
    {:ok, state} = do_free(state)
    {:reply, :ok, state}
  end

  # Matches when uid differs from reserved_by_uid
  def handle_call({:free, _uid}, _from, state) do
    {:reply, {:error, :not_allowed}, state}
  end

  # Not used anymore, but will be handy when adding a feature to alter reservation time
  def handle_continue(
        {:schedule_free, time_ms},
        state = %ParkingSpace{reserve_timer_ref: timer_ref}
      ) do
    Logger.info("Will be freed in #{time_ms / 1000} s")
    cancel_timer(timer_ref)
    timer_ref = Process.send_after(self(), :free, time_ms)
    {:noreply, %ParkingSpace{state | reserve_timer_ref: timer_ref}}
  end

  def handle_info(:free, state) do
    {:ok, state} = do_free(state)
    {:noreply, state}
  end

  defp do_free(state = %ParkingSpace{reserved_by_uid: nil}) do
    Logger.info("Parking space is not reserved")
    {:ok, state}
  end

  defp do_free(state = %ParkingSpace{}) do
    Logger.info("Freeing parking space")
    {:ok, reset_reservation(state)}
  end

  defp reset_reservation(state = %ParkingSpace{reserve_timer_ref: timer_ref}) do
    new_state = %ParkingSpace{state | reserve_timer_ref: nil, reserved_by_uid: nil, reserved_by_name: nil}
    cancel_timer(timer_ref)
    broadcast_state(new_state)
    new_state
  end
  defp update_reservation(state = %ParkingSpace{reserve_timer_ref: timer_ref}, uid, name) do
    cancel_timer(timer_ref)
    timer_ref = Process.send_after(self(), :free, @default_reserve_time)
    new_state = %ParkingSpace{
      state
    | reserve_timer_ref: timer_ref,
      reserved_by_uid: uid,
      reserved_by_name: name
    }

    Logger.info("Will be freed in #{@default_reserve_time / 1000} s")

    broadcast_state(new_state)
    new_state
  end

  defp broadcast_state(state = %ParkingSpace{id: id}) do
    status = get_broadcast_status(state)
    Phoenix.PubSub.broadcast(:parking_pool_pubsub, "parking_space:#{id}", {:state_change, status})
  end
  defp cancel_timer(nil), do: false
  defp cancel_timer(timer_ref), do: Process.cancel_timer(timer_ref)
  defp expire_time(nil), do: nil
  defp expire_time(timer_ref) do
    DateTime.utc_now |> DateTime.add(Process.read_timer(timer_ref), :millisecond)
  end
  defp get_broadcast_status(state = %ParkingSpace{id: id, reserved_by_uid: uid, reserved_by_name: name, reserve_timer_ref: timer_ref}), do:
  %{reserved: !is_nil(uid), reserved_by_uid: uid, reserved_by_name: name, expire_time: expire_time(timer_ref)}
end
