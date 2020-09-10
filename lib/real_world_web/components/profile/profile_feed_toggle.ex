defmodule RealWorldWeb.ProfileFeedToggle do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias Surface.Components.LivePatch

  property(current_user, :map)
  property(active_feed, :string)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="articles-toggle">
      <ul class="nav nav-pills outline-active">
        <li class="nav-item">

          <LivePatch
          class={{ "nav-link", active: @active_feed == "my_articles" }}
          label="My Articles"
          to="?feed=my_articles"/>

        </li>
        <li class="nav-item">

          <LivePatch
          class={{ "nav-link", active: @active_feed == "favorited_articles" }}
          label="Favorited Articles"
          to="?feed=favorited_articles"/>

        </li>
      </ul>
    </div>
    """
  end
end
