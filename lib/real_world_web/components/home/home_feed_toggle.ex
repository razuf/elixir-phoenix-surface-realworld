defmodule RealWorldWeb.HomeFeedToggle do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias Surface.Components.LivePatch

  property(current_user, :map)
  property(active_feed, :string)
  property(tag, :string)

  @impl true
  def render(assigns) do
    ~H"""
      <div class="feed-toggle">
        <ul class="nav nav-pills outline-active">
          <li class="nav-item" :if={{ user_signed_in?(@current_user) }}>

            <LivePatch
            class={{ "nav-link", active: @active_feed == "your_feed" }}
            label="Your Feed"
            to="?feed=your_feed"/>

          </li>
          <li class="nav-item">

            <LivePatch
            class={{ "nav-link", active: @active_feed == "global_feed" }}
            label="Global Feed"
            to="?feed=global_feed"/>

          </li>
          <li class="nav-item" :if={{ @tag }}>

            <LivePatch
            class={{ "nav-link", active: true }}
            label={{ "# " <> @tag }}
            to=""/>
          </li>
        </ul>
      </div>
    """
  end
end
