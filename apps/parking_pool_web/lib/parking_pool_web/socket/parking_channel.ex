defmodule ParkingPoolWeb.Socket.ParkingChannel do
  use Phoenix.Channel
  require Logger

  @impl true
   def join("parking_space:" <> parking_space_id, _payload, socket) do
    #if authorized?(payload) do
     Logger.info("User joined channel for #{inspect(parking_space_id)}")
     {:ok, socket}
    #else
    #  {:error, %{reason: "unauthorized"}}
    #end
   end

end
