defmodule RealWorldWeb.CommentCard do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers
  alias Surface.Components.LivePatch
  alias RealWorldWeb.Button

  property(comment, :map)
  property(current_user, :map)

  def render(assigns) do
    ~H"""
    <div class="card">
      <div class="card-block">
        <p class="card-text">{{ @comment["body"] }}</p>
      </div>
      <div class="card-footer">

        <LivePatch
        to={{Routes.main_path(@socket, :profile, @comment["author"]["username"])}}
        class="comment-author">
          <img src={{ get_user_image(@comment["author"]["image"]) }} class="comment-author-img" loading="lazy" />
        </LivePatch>
        &nbsp;
        <LivePatch
        to={{Routes.main_path(@socket, :profile, @comment["author"]["username"])}}
        class="comment-author">
          {{ @comment["author"]["username"] }}
        </LivePatch>
        <span class="date-posted">{{ format_datetime(@comment["createdAt"]) }}</span>
        <span class="mod-options" :if={{ @current_user.username == @comment["author"]["username"] }}>
          <Button
          class="btn"
          style="background-color: transparent; padding: 0px"
          click="delete_comment"
          value={{ @comment["id"] }}>
            <i class="ion-trash-a"></i>
          </Button>
        </span>
      </div>
    </div>
    """
  end
end
