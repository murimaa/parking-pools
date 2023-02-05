defmodule ParkingPoolWeb.Socket.ParkingSocket do
  use Phoenix.Socket
  require Logger

  channel "parking_space:*", ParkingPoolWeb.Socket.ParkingChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    Logger.info("Websocket connected")
    #{:ok, assign(socket, :user_id, params["user_id"])}
    {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.ChatWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
