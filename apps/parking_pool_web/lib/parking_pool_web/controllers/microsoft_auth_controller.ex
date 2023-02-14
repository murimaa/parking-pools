defmodule ParkingPoolWeb.MicrosoftAuthController do
  use ParkingPoolWeb, :controller

  require Logger

  @doc """
  Redirects to Microsoft Login
  """
  def login(conn, _) do
    redirect conn, external: OauthAzureActivedirectory.Client.authorize_url!
  end

  @doc """
  `callback/2` handles the callback from Microsoft Auth API redirect.
  """
  def callback(conn, _) do
    {:ok, claims} = OauthAzureActivedirectory.Client.callback_params(conn)
    conn
    |> configure_session(renew: true)
    |> put_session(:user_claims, claims)
    |> redirect(to: "/")
  end

  def logout(conn, _) do
    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(external: OauthAzureActivedirectory.Client.logout_url)
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

end
