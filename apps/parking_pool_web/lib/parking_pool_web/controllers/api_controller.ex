defmodule ParkingPoolWeb.ApiController do
  use ParkingPoolWeb, :controller
  require Logger

  def list(conn, _params) do
    spaces = ParkingPool.ParkingPoolSupervisor.list_spaces()
    |> Enum.map(fn {id, reserved, pid} -> %{id: id, reserved: reserved} end)
    json(conn, spaces)
  end

  def reserve(conn, %{"id" => id}) do
    ParkingPool.ParkingSpace.reserve(String.to_existing_atom(id), "user_id", "name")
    json(conn, %{id: id, reserved: true})
  end
  def free(conn, %{"id" => id}) do
    ParkingPool.ParkingSpace.free(String.to_existing_atom(id), "user_id")
    json(conn, %{id: id, reserved: false})
  end
end
