defmodule RealWorldWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers
  import Phoenix.LiveView

  alias RealWorld.Datastore
  alias RealWorld.User

  def assign_defaults(socket, %{"session_id" => session_id}) do
    current_user = Datastore.get_user_by_session_id(session_id) || Datastore.default_user()
    assign(socket, current_user: current_user, session_id: session_id)
  end

  # helper
  def user_signed_in?(%{:username => nil}) do
    false
  end

  def user_signed_in?(%{:username => _username}) do
    true
  end

  def user_signed_in?(_user) do
    false
  end

  def get_user_image("") do
    "https://static.productionready.io/images/smiley-cyrus.jpg"
  end

  def get_user_image(image) when is_binary(image) do
    image
  end

  def get_user_image(_nil) do
    "https://static.productionready.io/images/smiley-cyrus.jpg"
  end

  def following_text(true) do
    "Unfollow"
  end

  def following_text(_) do
    "Follow"
  end

  def following_click(true) do
    "unfollowing"
  end

  def following_click(_) do
    "follow"
  end

  def following_class(true) do
    "btn btn-sm action-btn btn-secondary"
  end

  def following_class(_) do
    "btn btn-sm action-btn btn-outline-secondary"
  end

  def favorited_text(true) do
    "Unfavorite Post"
  end

  def favorited_text(_) do
    "Favorite Post"
  end

  def favorited_button(true) do
    "btn-primary"
  end

  def favorited_button(_) do
    "btn-outline-primary"
  end

  def favorited_click(true) do
    "unfavorite"
  end

  def favorited_click(_) do
    "favorite"
  end

  def calc_pages(articles_count, limit_per_page) do
    if rem(articles_count, limit_per_page) != 0 do
      div(articles_count, limit_per_page) + 1
    else
      div(articles_count, limit_per_page)
    end
  end

  def active_class(page, page) do
    "page-item active"
  end

  def active_class(_page, _another_page) do
    "page-item"
  end

  def page_href("", page) do
    "?page=#{page}"
  end

  def page_href(url, page) do
    url <> "&page=#{page}"
  end
end
