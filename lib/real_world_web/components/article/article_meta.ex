defmodule RealWorldWeb.ArticleMeta do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias RealWorldWeb.Button
  alias Surface.Components.LivePatch

  property(article, :map)
  property(current_user, :map)

  def render(assigns) do
    ~H"""
    <div class="article-meta">

      <LivePatch to={{Routes.main_path(@socket, :profile, @article["author"]["username"])}}>
        <img src={{get_user_image(@article["author"]["image"])}} loading="lazy"/>
        </LivePatch>
        <div class="info">
          <LivePatch to={{Routes.main_path(@socket, :profile, @article["author"]["username"])}} class="author">
          {{@article["author"]["username"]}}
          </LivePatch>
          <span class="date">{{ format_datetime(@article["createdAt"]) }}</span>
      </div>

      <Button :if={{ @current_user.username != @article["author"]["username"] }}
      click={{ following_click(@article["author"]["following"]) }}
      value={{ @article["author"]["username"] }}
      class={{ following_class(@article["author"]["following"]) }} >
        <i class="ion-plus-round"></i>
        &nbsp;
        <span>{{ following_text(@article["author"]["following"]) }} {{ @article["author"]["username"] }}</span>
      </Button>

      <LivePatch :if={{ @current_user.username == @article["author"]["username"] }}
      to={{Routes.main_path(@socket, :editor, @article["slug"])}}
      class="btn btn-sm btn-outline-secondary">
        <i class="ion-edit"></i>
        <span>&nbsp;Edit Article</span>
      </LivePatch>
      &nbsp;&nbsp;
      <Button :if={{ @current_user.username != @article["author"]["username"] }}
      click={{ favorited_click(@article["favorited"]) }}
      value={{ @article["slug"] }}
      class="btn btn-sm {{ favorited_button(@article["favorited"]) }}">
      <i class="ion-heart"></i>
      &nbsp;
      {{ favorited_text(@article["favorited"]) }} <span class="counter">({{ @article["favoritesCount"] }})</span>
      </Button>

      <Button :if={{ @current_user.username == @article["author"]["username"] }}
      click="delete_article"
      class="btn btn-outline-danger btn-sm">
      <i class="ion-trash-a"></i>
      &nbsp;
      <span>Delete Article</span>
      </Button>
    </div>
    """
  end
end
