defmodule ParkingPoolWeb.PageController do
  use ParkingPoolWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    claims = get_session(conn, :user_claims)
    conn = conn
           |> assign(:name, claims["name"])
           |> assign(:uid, claims["oid"])
    render(conn, :home, layout: false)
  end
end
