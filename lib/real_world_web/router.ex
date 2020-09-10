defmodule RealWorldWeb.Router do
  use RealWorldWeb, :router

  alias RealWorld.Datastore
  alias RealWorldWeb.Router.Helpers, as: Routes

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:put_root_layout, {RealWorldWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", RealWorldWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live("/login", MainLive, :login)
    live("/register", MainLive, :register)
  end

  scope "/", RealWorldWeb do
    pipe_through([:browser, :require_authenticated_user])

    live("/settings", MainLive, :settings)
    live("/editor", MainLive, :editor)
    live("/editor/:slug", MainLive, :editor)
    live("/logout", MainLive, :logout)
  end

  scope "/", RealWorldWeb do
    pipe_through(:browser)

    live("/", MainLive, :home)
    live("/article/:slug", MainLive, :article)
    live("/profile/:username", MainLive, :profile)

    live("/*path", MainLive, :default_redirect)
  end

  # Other scopes may use custom stacks.
  # scope "/api", RealWorldWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: RealWorldWeb.Telemetry)
    end
  end

  def fetch_current_user(conn, _opts) do
    if session_id = get_session(conn, :session_id) do
      current_user = Datastore.get_user_by_session_id(session_id)
      assign(conn, :current_user, current_user)
    else
      conn
      |> put_session(:session_id, Ecto.UUID.generate())
    end
  end

  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: Routes.main_path(conn, :home))
      |> halt()
    else
      conn
    end
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> redirect(to: Routes.main_path(conn, :login))
      |> halt()
    end
  end
end
