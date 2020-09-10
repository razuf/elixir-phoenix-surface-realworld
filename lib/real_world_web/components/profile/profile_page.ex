defmodule RealWorldWeb.ProfilePage do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias RealWorldWeb.ProfileFeedToggle
  alias RealWorldWeb.ListArticles
  alias RealWorldWeb.PaginationArticles
  alias RealWorldWeb.Button
  alias Surface.Components.LivePatch

  property(profile_user, :map, default: %{})
  property(current_user, :map)
  property(articles, :list, default: [])
  property(pages, :integer, default: 0)
  property(active_page, :integer, default: 1)
  property(feed, :string, default: "")

  @impl true
  def render(assigns) do
    ~H"""
    <div class="profile-page">
      <div class="user-info">
        <div class="container">
          <div class="row">
            <div class="col-xs-12 col-md-10 offset-md-1">
              <img src={{ get_user_image(@profile_user["image"]) }} class="user-img" loading="lazy"/>
              <h4>{{ @profile_user["username"] }}</h4>
              <p>
              {{ @profile_user["bio"] }}
              </p>
              <Button :if={{ @current_user.username != @profile_user["username"] }}
              click={{ following_click(@profile_user["following"]) }}
              value={{ @profile_user["username"] }}
              class={{ following_class(@profile_user["following"]) }}>
                <i class="ion-plus-round"></i>
                &nbsp;
                {{ following_text(@profile_user["following"]) }} {{ @profile_user["username"] }}
              </Button>
              <LivePatch :if={{ @current_user.username == @profile_user["username"] }}
              class="btn btn-sm btn-outline-secondary action-btn" to={{Routes.main_path(@socket, :settings)}}>
                <i class="ion-gear-a"></i>&nbsp;Edit Profile Settings
              </LivePatch>
            </div>
          </div>
        </div>
      </div>

      <div class="container">
        <div class="row">
          <div class="col-xs-12 col-md-10 offset-md-1">

            <ProfileFeedToggle
            current_user={{ @current_user }}
            active_feed={{ @feed }} />

            <ListArticles articles={{ @articles }}/>

            <PaginationArticles url="?feed={{ @feed }}" active_page={{ @active_page }} pages={{ @pages }}/>

          </div>
        </div>
      </div>
    </div>
    """
  end
end
