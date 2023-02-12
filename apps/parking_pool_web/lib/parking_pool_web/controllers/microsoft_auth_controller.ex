defmodule ParkingPoolWeb.MicrosoftAuthController do
  use ParkingPoolWeb, :controller


  @doc """
  Redirects to Microsoft Login
  """
  def login(conn, _) do
    base_uri = ParkingPoolWeb.Endpoint.static_url
    redirect_uri = "#{base_uri}/auth/microsoft/callback"
    redirect conn, external: AzureADOpenId.authorize_url!(redirect_uri)
  end

  @doc """
  `callback/2` handles the callback from Microsoft Auth API redirect.
  """
  def callback(conn, _) do
    {:ok, claims} = AzureADOpenId.handle_callback!(conn)

    conn
    |> put_session(:user_claims, claims)
    |> redirect(to: "/")
  end
end
