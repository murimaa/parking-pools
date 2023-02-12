defmodule ParkingPoolWeb.MicrosoftAuthController do
  use ParkingPoolWeb, :controller

  require Logger

  @doc """
  Redirects to Microsoft Login
  """
  def login(conn, _) do
    base_uri = ParkingPoolWeb.Endpoint.static_url
    redirect_uri = "#{base_uri}/auth/microsoft/callback"
    redirect conn, external: AzureADOpenId.authorize_url!(redirect_uri)
  end

  def logout(conn, _) do
    base_uri = ParkingPoolWeb.Endpoint.static_url
    redirect_uri = "#{base_uri}/auth/logout/callback"
    Logger.debug("User logged out. Calling Microsoft backchannel logout #{inspect redirect_uri}")
    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(external: AzureADOpenId.logout_url(redirect_uri))
  end

  @doc """
  `logout_callback/3` is triggered from an SSO logout
  """
  def logout_callback(conn, _) do
    Logger.debug("Received frontchannel logout callback, removing session")
    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  @doc """
  `callback/2` handles the callback from Microsoft Auth API redirect.
  """
  def callback(conn, _) do
    {:ok, claims} = AzureADOpenId.handle_callback!(conn)

    conn
    |> configure_session(renew: true)
    |> put_session(:user_claims, claims)
    |> redirect(to: "/")
  end
end
