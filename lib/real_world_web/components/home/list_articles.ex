defmodule RealWorldWeb.ListArticles do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers
  alias RealWorldWeb.TagPill
  alias Surface.Components.LivePatch
  alias RealWorldWeb.Button

  property(articles, :list, required: false)

  def render(assigns) do
    ~H"""
    <div class="article-preview" :for={{ article <- @articles }}>
      <div class="article-meta">

        <LivePatch to={{Routes.main_path(@socket, :profile, article["author"]["username"])}}>
          <img src={{get_user_image(article["author"]["image"])}} loading="lazy" />
          </LivePatch>
          <div class="info">
            <LivePatch to={{Routes.main_path(@socket, :profile, article["author"]["username"])}} class="author">
            {{article["author"]["username"]}}
            </LivePatch>
            <span class="date">{{ format_datetime(article["createdAt"]) }}</span>
        </div>

        <Button
        class="btn btn-sm pull-xs-right {{ favorited_button(article["favorited"]) }}"
        click={{ favorited_click(article["favorited"]) }}
        value={{ article["slug"] }}>
          <i class="ion-heart"></i>
          <span>{{ article["favoritesCount"] }}</span>
        </Button>

      </div>
      <LivePatch to={{Routes.main_path(@socket, :article, article["slug"])}} class="preview-link">
        <h1>{{ article["title"] }}</h1>
        <p>{{ article["description"] }}</p>
        <span>Read more...</span>
        <ul class="tag-list">
          <TagPill :for={{ tag <- article["tagList"] }}>
            {{ tag }}
          </TagPill>
        </ul>
      </LivePatch>

    </div>
    """
  end
end
