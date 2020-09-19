defmodule RealWorldWeb.LiveHelpers do
  import Phoenix.LiveView
  import Ecto.Changeset

  alias RealWorld.Datastore

  def assign_defaults_connected(socket, %{"session_id" => session_id}) do
    current_user = Datastore.get_user_by_session_id(session_id) || Datastore.default_user()

    socket
    |> default_assigns()
    |> assign(
      session_id: session_id,
      current_user: current_user
    )
  end

  def assign_defaults(socket, %{"session_id" => session_id}) do
    socket
    |> default_assigns()
    |> assign(
      session_id: session_id,
      current_user: Datastore.default_user()
    )
  end

  defp default_assigns(socket) do
    assign(socket,
      profile_user: nil,
      articles: [],
      tags: [],
      pages: 0,
      active_page: 1,
      article: nil,
      tag: nil,
      submit: nil,
      change: nil,
      changeset: nil,
      feed: nil
    )
  end

  def get_field(%Ecto.Changeset{} = changeset, key) do
    Ecto.Changeset.get_field(changeset, key, "")
  end

  def get_field(nil, _key) do
    ""
  end

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

  def following_text(_false) do
    "Follow"
  end

  def following_click(true) do
    "unfollowing"
  end

  def following_click(_false) do
    "follow"
  end

  def following_class(true) do
    "btn btn-sm action-btn btn-secondary"
  end

  def following_class(_false) do
    "btn btn-sm action-btn btn-outline-secondary"
  end

  def favorited_text(true) do
    "Unfavorite Post"
  end

  def favorited_text(_false) do
    "Favorite Post"
  end

  def favorited_button(true) do
    "btn-primary"
  end

  def favorited_button(_false) do
    "btn-outline-primary"
  end

  def favorited_click(true) do
    "unfavorite"
  end

  def favorited_click(_false) do
    "favorite"
  end

  def calc_pages(articles_count, limit_per_page) do
    if rem(articles_count, limit_per_page) != 0 do
      div(articles_count, limit_per_page) + 1
    else
      div(articles_count, limit_per_page)
    end
  end

  def nav_link_active(true) do
    "nav-link active"
  end

  def nav_link_active(_false) do
    "nav-link"
  end

  def active_class(active_page, active_page) do
    "page-item active"
  end

  def active_class(_active_page, _another_page) do
    "page-item"
  end

  def page_href("", page) do
    "?page=#{page}"
  end

  def page_href(url, page) do
    url <> "&page=#{page}"
  end

  def feed_url(feed) do
    "?feed=#{feed}"
  end

  @doc """
  Receives a validation tuple from a changeset and flatten the error message
  """
  def flatten_error_message({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  def format_datetime(nil) do
    ""
  end

  def format_datetime(%{day: day, month: month, year: year}) do
    "#{format_month(month)} #{day}, #{year}"
  end

  def format_datetime(datetime) do
    %{day: day, month: month, year: year} = NaiveDateTime.from_iso8601!(datetime)
    "#{format_month(month)} #{day}, #{year}"
  end

  defp format_month(1), do: "January"
  defp format_month(2), do: "February"
  defp format_month(3), do: "March"
  defp format_month(4), do: "April"
  defp format_month(5), do: "May"
  defp format_month(6), do: "June"
  defp format_month(7), do: "July"
  defp format_month(8), do: "August"
  defp format_month(9), do: "September"
  defp format_month(10), do: "October"
  defp format_month(11), do: "November"
  defp format_month(12), do: "December"
end
