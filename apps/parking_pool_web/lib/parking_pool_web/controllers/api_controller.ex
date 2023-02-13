defmodule ParkingPoolWeb.ApiController do
  use ParkingPoolWeb, :controller
  require Logger

  def list(conn, _params) do
    {uid, _name} = conn.assigns[:user]
    spaces = ParkingPool.ParkingPoolSupervisor.list_spaces()
             |> Enum.map(fn {id, state, pid} -> %{id: id} end)
             |> Enum.sort_by(& &1.id)
    json(conn, spaces)
  end

  def reserve(conn, %{"id" => id}) do
    {uid, name} = conn.assigns[:user]
    ParkingPool.ParkingSpace.reserve(String.to_existing_atom(id), uid, name)
    json(conn, %{id: id, reserved: true})
  end
  def free(conn, %{"id" => id}) do
    {uid, _} = conn.assigns[:user]
    case ParkingPool.ParkingSpace.free(String.to_existing_atom(id), uid) do
      :ok -> json(conn, %{id: id, reserved: false})
      {:error, :not_reserved} -> json(conn, %{id: id, reserved: false})
      {:error, _error} -> json(conn, %{id: id, reserved: true})
    end

  end
end
