defmodule RealWorldWeb.HomePage do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias RealWorldWeb.HomeFeedToggle
  alias RealWorldWeb.ListArticles
  alias RealWorldWeb.PaginationArticles
  alias Surface.Components.LivePatch

  property(articles, :list, default: [])
  property(tags, :list, default: [])
  property(feed, :string, default: "")
  property(active_page, :integer, default: 1)
  property(pages, :integer, default: 0)
  property(current_user, :map)
  property(tag, :string)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="home-page">
    <div class="banner">
      <div class="container">
        <h1 class="logo-font">conduit</h1>
        <p>A place to share your Elixir knowledge.</p>
      </div>
    </div>

    <div class="container page">
      <div class="row">
        <div class="col-md-9">

          <HomeFeedToggle
          current_user={{ @current_user }}
          active_feed={{ @feed }}
          tag={{ @tag }}/>

          <ListArticles articles={{ @articles }}/>

          <PaginationArticles url="?feed={{ @feed }}" active_page={{ @active_page }} pages={{ @pages }}/>

        </div>

        <div class="col-md-3">
          <div class="sidebar">
            <p>Popular Tags</p>
            <div class="tag-list">

              <LivePatch
              :for={{ tag <- @tags }}
              class={{ "tag-pill tag-default" }}
              label={{ tag }}
              to="?feed=tag_{{ tag }}"/>

            </div>
          </div>
        </div>

        </div>
      </div>
    </div>
    """
  end
end
