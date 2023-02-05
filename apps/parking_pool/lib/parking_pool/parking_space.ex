defmodule ParkingPool.ParkingSpace do
  use GenServer
  alias __MODULE__
  require Logger

  defstruct [:display_name, :reserved_by_name, :reserved_by_uid, :reserve_timer_ref]

  @default_reserve_time 5_000

  def start_link(name, display_name) do
    GenServer.start_link(__MODULE__, display_name, name: name)
  end

  def init(display_name) do
    Logger.info("Initializing parking space #{display_name}")
    {:ok, %ParkingSpace{display_name: display_name}}
  end

  def reserve(spot, uid, display_name), do: GenServer.call(spot, {:reserve, uid, display_name})
  def free(spot, uid), do: GenServer.call(spot, {:free, uid})
  def reserved?(spot), do: GenServer.call(spot, :reserved?)

  def handle_call(:reserved?, _from, state = %ParkingSpace{reserved_by_uid: nil}), do: {:reply, false, state}

  def handle_call(:reserved?, _from, state), do: {:reply, true, state}

  def handle_call({:reserve, uid, name}, _from, state = %ParkingSpace{reserved_by_uid: nil}) do
    Logger.info("Reserving parking spot for: #{uid}, #{name}")

    state = %ParkingSpace{
      state
      | reserve_timer_ref: nil,
        reserved_by_uid: uid,
        reserved_by_name: name
    }

    {:reply, :ok, state, {:continue, {:schedule_free, @default_reserve_time}}}
  end

  def handle_call({:reserve, display_name, uid}, _from, state) do
    {:reply, :already_reserved, state}
  end

  def handle_call({:free, _uid}, _from, state) do
    {:ok, state} = do_free(state)
    {:reply, :ok, state}
  end

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

  defp do_free(state = %ParkingSpace{reserve_timer_ref: timer_ref}) do
    Logger.info("Freeing parking space")
    {:ok, reset_state(state)}
  end

  defp reset_state(state = %ParkingSpace{reserve_timer_ref: timer_ref}) do
    cancel_timer(timer_ref)
    %ParkingSpace{state | reserve_timer_ref: nil, reserved_by_uid: nil, reserved_by_name: nil}
  end

  defp cancel_timer(nil), do: false
  defp cancel_timer(timer_ref), do: Process.cancel_timer(timer_ref)
end
