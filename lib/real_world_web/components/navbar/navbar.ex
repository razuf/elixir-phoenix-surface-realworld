defmodule RealWorldWeb.Navbar do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers
  alias Surface.Components.LivePatch

  property(current_user, :map)
  property(live_action, :atom)

  def render(assigns) do
    ~H"""
    <nav class="navbar navbar-light">
      <div class="container">
        <LivePatch class="navbar-brand" to={{Routes.main_path(@socket, :home)}}>
          conduit
        </LivePatch>
        <ul class="nav navbar-nav pull-xs-right">
          <li class={{ "nav-item", active: :home == @live_action }}>
            <LivePatch class="nav-link"  to={{Routes.main_path(@socket, :home)}}>
              Home
            </LivePatch>
          </li>
          <li class={{ "nav-item", active: :editor == @live_action }} :if={{ user_signed_in?(@current_user) }}>
            <LivePatch class="nav-link" to={{Routes.main_path(@socket, :editor)}}>
              <i class="ion-compose"></i>&nbsp;New Post
            </LivePatch>
            </li>
            <li class={{ "nav-item", active: :settings == @live_action }} :if={{ user_signed_in?(@current_user) }}>
            <LivePatch class="nav-link" to={{Routes.main_path(@socket, :settings)}}>
              <i class="ion-gear-a"></i>&nbsp;Settings
            </LivePatch>
          </li>
          <li class={{ "nav-item", active: :profile == @live_action }} :if={{ user_signed_in?(@current_user) }}>
            <LivePatch class="nav-link" to={{Routes.main_path(@socket, :profile, @current_user.username)}}>
              <img class="user-pic" src={{ get_user_image(@current_user.image) }} loading="lazy">
              {{ @current_user.username }}
            </LivePatch>
          </li>
          <li class="nav-item" :if={{ user_signed_in?(@current_user) }}>
            <LivePatch class="nav-link"  to={{Routes.main_path(@socket, :logout)}}>
              Sign out
            </LivePatch>
          </li>
          <li class={{ "nav-item", active: :login == @live_action }} :if={{ not user_signed_in?(@current_user) }}>
            <LivePatch class="nav-link" to={{Routes.main_path(@socket, :login)}}>
              Sign in
            </LivePatch>
          </li>
          <li class={{ "nav-item", active: :register == @live_action }} :if={{ not user_signed_in?(@current_user) }}>
            <LivePatch class="nav-link" to={{Routes.main_path(@socket, :register)}}>
             Sign up
            </LivePatch>
          </li>
        </ul>
      </div>
    </nav>
    """
  end
end
