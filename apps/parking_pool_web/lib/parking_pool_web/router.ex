defmodule ParkingPoolWeb.Router do
  use ParkingPoolWeb, :router
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ParkingPoolWeb.Layouts, :root}
    plug :put_secure_browser_headers

    plug :put_user_token
    plug :put_user
  end

  pipeline :csrf do
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session

    plug :put_user
  end

  scope "/", ParkingPoolWeb do
    pipe_through [:browser, :csrf]

    get "/", PageController, :home
    get "/auth/microsoft", MicrosoftAuthController, :login
    get "/auth/logout", MicrosoftAuthController, :logout
  end

  scope "/", ParkingPoolWeb do
    pipe_through :browser
    post "/auth/microsoft/callback", MicrosoftAuthController, :callback
    post "/auth/microsoft/logout", MicrosoftAuthController, :logout_callback

  end
  scope "/api", ParkingPoolWeb do
    pipe_through :api

    get "/spaces",  ApiController, :list
    post "/space/:id/reserve",  ApiController, :reserve
    post "/space/:id/free",  ApiController, :free
  end

  defp put_user_token(conn, _) do
    if user_claims = conn |> get_session(:user_claims) do
      token = Phoenix.Token.sign(conn, "user socket", user_claims["oid"])
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  defp put_user(conn, _) do
    if user_claims = conn |> get_session(:user_claims) do
      oid = user_claims["oid"]
      name = user_claims["name"]
      assign(conn, :user, {oid, name})
    else
      conn
    end
  end
  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:parking_pool_web, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ParkingPoolWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
