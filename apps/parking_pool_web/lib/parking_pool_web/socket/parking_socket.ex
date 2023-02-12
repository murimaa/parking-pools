defmodule ParkingPoolWeb.Socket.ParkingSocket do
  use Phoenix.Socket
  require Logger

  # 1209600 is equivalent to two weeks in seconds
  @token_max_age 1_209_600

  channel "parking_space:*", ParkingPoolWeb.Socket.ParkingChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: @token_max_age) do
      {:ok, user_id} ->
        Logger.info("Websocket connected, user_id: #{user_id}")
        {:ok, assign(socket, :user_id, user_id)}
      {:error, reason} ->
        :error
    end
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
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
