defmodule ParkingPool.ParkingPoolSupervisor do
  use Supervisor

  alias ParkingPool.ParkingSpace

  # Hard coded list of parking spaces
  @parking_pool [
    :parking_space_1,
    :parking_space_2,
    :parking_space_3,
    :parking_space_4,
    :parking_space_5,
    :parking_space_6
  ]

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    # Map parking spaces in @parking_pool to child specs.
    # Starts a process for each parking space.
    children =
      @parking_pool
      |> Enum.map(&%{id: &1, start: {ParkingSpace, :start_link, [&1, &1]}})

    # :one_for_one strategy: if a child process crashes, only that process is restarted.
    Supervisor.init(children, strategy: :one_for_one)
  end

  def list_spaces() do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn {id, pid, _, _} -> {id, ParkingSpace.reserved?(pid), pid} end)
  end
end
