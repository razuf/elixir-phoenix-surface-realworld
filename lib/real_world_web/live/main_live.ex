defmodule RealWorldWeb.MainLive do
  use Surface.LiveView
  use RealWorldWeb, :surface_view_helpers

  alias RealWorldWeb.Navbar
  alias RealWorldWeb.HomePage
  alias RealWorldWeb.LoginPage
  alias RealWorldWeb.RegisterPage
  alias RealWorldWeb.ArticlePage
  alias RealWorldWeb.EditorPage
  alias RealWorldWeb.ProfilePage
  alias RealWorldWeb.SettingsPage

  alias RealWorld.Datastore

  @limit_per_page 5

  data(current_user, :map, default: Datastore.default_user())
  data(tags, :list, default: [])
  data(pages, :integer, default: 0)
  data(active_page, :integer, default: 1)
  data(feed, :string, default: "")
  data(tag, :string, default: nil)
  data(article, :map, default: nil)
  data(comments, :list, default: [])
  data(profile_user, :map, default: %{})
  data(articles, :list, default: [])
  data(changeset, :changeset)
  data(submit, :event)
  data(change, :event)

  @impl true
  def render(assigns) do
    ~H"""
     <Navbar current_user={{@current_user}} live_action={{@live_action}} />

     <HomePage
     :if={{@live_action == :home}}
     current_user={{@current_user}}
     articles={{@articles}}
     tags={{@tags}}
     pages={{@pages}}
     active_page={{@active_page}}
     tag={{@tag}}
     feed={{@feed}}/>

     <LoginPage
     :if={{@live_action == :login}}
     submit={{@submit}}
     changeset={{@changeset}}/>

     <RegisterPage
     :if={{@live_action == :register}}
     change={{@change}}
     submit={{@submit}}
     changeset={{@changeset}}/>

     <ArticlePage
     :if={{@live_action == :article}}
     :if={{@article}}
     current_user={{@current_user}}
     article={{@article}}
     comments={{@comments}}
     submit={{@submit}}
     changeset={{@changeset}}/>

     <EditorPage
     :if={{@live_action == :editor}}
     submit={{@submit}}
     changeset={{@changeset}}/>

     <ProfilePage
     :if={{@live_action == :profile}}
     :if={{@profile_user}}
     profile_user={{@profile_user}}
     current_user={{@current_user}}
     articles={{@articles}}
     pages={{@pages}}
     active_page={{@active_page}}
     feed={{@feed}}/>

     <SettingsPage
     :if={{@live_action == :settings}}
     change={{@change}}
     submit={{@submit}}
     changeset={{@changeset}}/>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      {:ok, assign_defaults_connected(socket, session)}
    else
      {:ok, assign_defaults(socket, session)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    if connected?(socket) do
      {:noreply, apply_action(socket, params, socket.assigns.live_action)}
    else
      {:noreply, socket}
    end
  end

  ####################################################################################
  # handle live_actions
  ####################################################################################

  defp apply_action(socket, params, :home) do
    feed = params["feed"] || ""
    active_page = String.to_integer(params["page"] || "1")
    offset = (active_page - 1) * @limit_per_page

    socket
    |> assign(active_page: active_page)
    |> assign(feed: feed)
    |> assign(offset: offset)
    |> update_feed()
    |> maybe_update_tags()
  end

  defp update_feed(socket) do
    current_user = socket.assigns.current_user
    feed = socket.assigns.feed
    session_id = socket.assigns.session_id
    offset = socket.assigns.offset || 0

    case {feed, user_signed_in?(current_user)} do
      {"tag_" <> tag, _any_case} ->
        send(self(), {:get_articles_by_tag, tag, offset, @limit_per_page, session_id})

        assign(socket, feed: feed, tag: tag)

      {user_feed, true} when user_feed == "your_feed" or user_feed == "" ->
        send(self(), {:feed_articles, offset, @limit_per_page, session_id})

        assign(socket, feed: "your_feed", tag: nil)

      _default_global_feed ->
        send(self(), {:list_articles, offset, @limit_per_page, session_id})

        assign(socket, feed: "global_feed", tag: nil)
    end
  end

  defp maybe_update_tags(socket) do
    unless length(socket.assigns.tags) > 0 do
      send(self(), {:list_tags, socket.assigns.session_id})

      tags = []
      assign(socket, tags: tags)
    else
      socket
    end
  end

  defp apply_action(socket, params, :article) do
    slug = params["slug"] || ""
    session_id = socket.assigns.session_id
    send(self(), {:get_article_by_slug, slug, session_id})

    socket
    |> assign(changeset: Datastore.change_new_comment())
  end

  defp apply_action(socket, params, :editor) do
    if slug = params["slug"] do
      editor_edit_article(socket, slug)
    else
      editor_create_article(socket)
    end
  end

  defp editor_edit_article(socket, slug) do
    session_id = socket.assigns.current_user.session_id
    article = Datastore.get_article_by_slug(slug, session_id)

    if article do
      changeset = Datastore.change_article(article)

      socket
      |> assign(article: article)
      |> assign(changeset: changeset)
      |> assign(submit: "update_article")
    else
      push_redirect(socket, to: Routes.main_path(socket, :home))
    end
  end

  defp editor_create_article(socket) do
    changeset = Datastore.change_new_article()

    socket
    |> assign(article: nil)
    |> assign(changeset: changeset)
    |> assign(submit: "create_article")
  end

  defp apply_action(socket, _params, :settings) do
    changeset = Datastore.change_user(socket.assigns.current_user, %{})

    socket
    |> assign(submit: "settings")
    |> assign(change: "change_settings")
    |> assign(changeset: changeset)
  end

  defp apply_action(socket, _params, :login) do
    socket
    |> assign(submit: "login")
    |> assign(changeset: Datastore.change_user())
  end

  defp apply_action(socket, _params, :register) do
    socket
    |> assign(submit: "register")
    |> assign(changeset: Datastore.change_user())
    |> assign(change: "change_register")
  end

  defp apply_action(socket, _params, :logout) do
    Datastore.logout(socket.assigns.current_user)

    socket
    |> push_redirect(to: Routes.main_path(socket, :home))
  end

  defp apply_action(socket, params, :profile) do
    feed = params["feed"] || "my_articles"
    active_page = String.to_integer(params["page"] || "1")
    username = params["username"] || ""
    session_id = socket.assigns.session_id

    if profile_user = Datastore.get_profile_by_username(username, session_id) do
      socket
      |> assign(active_page: active_page)
      |> assign(feed: feed)
      |> assign(profile_user: profile_user)
      |> update_profile_articles(feed)
    else
      push_redirect(socket, to: Routes.main_path(socket, :home))
    end
  end

  defp update_profile_articles(socket, feed) do
    user = socket.assigns.profile_user
    session_id = socket.assigns.current_user.session_id
    active_page = socket.assigns.active_page
    offset = (active_page - 1) * @limit_per_page

    case feed do
      "favorited_articles" ->
        send(
          self(),
          {:get_articles_favorited_by_username, user["username"], offset, @limit_per_page,
           session_id}
        )

        socket

      _my_articles ->
        send(
          self(),
          {:get_articles_by_username, user["username"], offset, @limit_per_page, session_id}
        )

        socket
    end
  end

  defp apply_action(socket, _params, :default_redirect) do
    socket
    |> push_redirect(to: Routes.main_path(socket, :home))
  end

  ####################################################################################
  # handle events
  ####################################################################################

  ###### login

  @impl true
  def handle_event("login", %{"form" => form_params}, socket) do
    case Datastore.auth_user(form_params) do
      {:ok, user_attrs} ->
        {:ok, _current_user} = Datastore.login(user_attrs, socket.assigns.session_id)

        {:noreply,
         socket
         |> push_redirect(to: Routes.main_path(socket, :home))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  ###### register

  def handle_event("change_register", %{"form" => form_params}, socket) do
    changeset = Datastore.change_user(form_params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("register", %{"form" => form_params}, socket) do
    session_id = socket.assigns.session_id

    case Datastore.register_user(form_params, session_id) do
      {:ok, user} ->
        {:ok, _current_user} = Datastore.login(user, session_id)

        {:noreply,
         socket
         |> push_redirect(to: Routes.main_path(socket, :home))}

      {:error, %Ecto.Changeset{} = changeset} ->
        # Datastore.store_articles(60, 0, session_id)

        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  ###### settings

  def handle_event("change_settings", %{"form" => form_params}, socket) do
    {:noreply, assign(socket, changeset: Datastore.change_user(form_params))}
  end

  def handle_event("settings", %{"form" => form_params}, socket) do
    session_id = socket.assigns.current_user.session_id

    case Datastore.update_user(form_params, session_id) do
      {:ok, user} ->
        {:noreply, push_redirect(socket, to: Routes.main_path(socket, :profile, user.username))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  ###### editor

  def handle_event("update_article", %{"form" => form_params}, socket) do
    slug = socket.assigns.article["slug"]
    form_params = Map.merge(form_params, %{"slug" => slug})
    editor_article_action(socket, form_params, &Datastore.update_article/2)
  end

  def handle_event("create_article", %{"form" => form_params}, socket) do
    editor_article_action(socket, form_params, &Datastore.create_article/2)
  end

  defp editor_article_action(socket, form_params, article_function) do
    session_id = socket.assigns.current_user.session_id

    case article_function.(form_params, session_id) do
      {:ok, article} ->
        {:noreply, push_redirect(socket, to: Routes.main_path(socket, :article, article["slug"]))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  ###### article

  def handle_event("delete_article", _params, socket) do
    article = socket.assigns.article
    session_id = socket.assigns.current_user.session_id

    if article && :ok == Datastore.delete_article(article, session_id) do
      {:noreply, push_redirect(socket, to: Routes.main_path(socket, :home))}
    else
      {:noreply, socket}
    end
  end

  ###### comment

  def handle_event("create_comment", %{"form" => form_params}, socket) do
    article = socket.assigns.article
    current_user = socket.assigns.current_user
    session_id = socket.assigns.current_user.session_id

    if article && current_user do
      case Datastore.create_comment_for_slug(article["slug"], form_params, session_id) do
        {:ok, _comment} ->
          send(self(), {:get_comments_from_one_article, article["slug"], session_id})

          changeset = Datastore.change_new_comment()
          {:noreply, assign(socket, changeset: changeset)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      push_redirect(socket, to: Routes.main_path(socket, :home))
    end
  end

  def handle_event("delete_comment", %{"value" => id}, socket) do
    current_user = socket.assigns.current_user
    article = socket.assigns.article
    session_id = socket.assigns.current_user.session_id

    if user_signed_in?(current_user) && article &&
         :ok == Datastore.delete_comment_by_id(article, id, session_id) do
      comments = Datastore.get_comments_from_one_article(article["slug"], session_id)
      {:noreply, assign(socket, comments: comments)}
    else
      {:noreply, socket}
    end
  end

  # #### favorited article

  def handle_event("unfavorite", %{"value" => slug}, socket) do
    if user_signed_in?(socket.assigns.current_user) do
      toggle_favorited(:unfavorite, slug, socket)
    else
      {:noreply, push_redirect(socket, to: Routes.main_path(socket, :login))}
    end
  end

  def handle_event("favorite", %{"value" => clicked_slug}, socket) do
    if user_signed_in?(socket.assigns.current_user) do
      toggle_favorited(:favorite, clicked_slug, socket)
    else
      {:noreply, push_redirect(socket, to: Routes.main_path(socket, :login))}
    end
  end

  defp toggle_favorited(favorited_action, clicked_slug, socket) do
    session_id = socket.assigns.session_id

    if socket.assigns.article do
      case Datastore.toggle_favorited_article(favorited_action, clicked_slug, session_id) do
        {:ok, updated_article} ->
          {:noreply, assign(socket, article: updated_article)}

        _error ->
          {:noreply, socket}
      end
    else
      updated_articles =
        Enum.map(socket.assigns.articles, fn article ->
          toggle_for_slug(article["slug"], clicked_slug, article, favorited_action, session_id)
        end)

      {:noreply, assign(socket, articles: updated_articles)}
    end
  end

  defp toggle_for_slug(slug, slug, article, favorited_action, session_id) do
    case Datastore.toggle_favorited_article(favorited_action, slug, session_id) do
      {:ok, updated_article} ->
        updated_article

      _error ->
        article
    end
  end

  defp toggle_for_slug(_slug, _clicked_other_slug, article, _action, _session_id) do
    article
  end

  ###### follow user

  def handle_event("unfollowing", %{"value" => username}, socket) do
    set_following_to(:unfollowing, username, socket)
  end

  def handle_event("follow", %{"value" => username}, socket) do
    set_following_to(:follow, username, socket)
  end

  defp set_following_to(following_action, username, socket) do
    current_user = socket.assigns.current_user

    if user_signed_in?(current_user) do
      article = socket.assigns.article
      session_id = socket.assigns.current_user.session_id
      updated_profile = Datastore.toggle_following_user(following_action, username, session_id)

      case updated_profile do
        :error ->
          {:noreply, socket}

        updated_profile ->
          if article do
            # toggle in article page
            updated_article = Map.put(article, "author", updated_profile)
            {:noreply, assign(socket, article: updated_article)}
          else
            # toggle in profile page
            {:noreply, assign(socket, profile_user: updated_profile)}
          end
      end
    else
      {:noreply, push_redirect(socket, to: Routes.main_path(socket, :login))}
    end
  end

  @impl true
  def handle_info({:list_articles, offset, limit_per_page, session_id}, socket) do
    articles = Datastore.list_articles(offset, limit_per_page, session_id)

    {:noreply, update_articles(socket, articles)}
  end

  def handle_info({:feed_articles, offset, limit_per_page, session_id}, socket) do
    articles = Datastore.feed_articles(offset, limit_per_page, session_id)

    {:noreply, update_articles(socket, articles)}
  end

  def handle_info({:get_articles_by_tag, tag, offset, limit_per_page, session_id}, socket) do
    articles = Datastore.get_articles_by_tag(tag, offset, limit_per_page, session_id)

    {:noreply, update_articles(socket, articles)}
  end

  def handle_info(
        {:get_articles_favorited_by_username, username, offset, limit_per_page, session_id},
        socket
      ) do
    articles =
      Datastore.get_articles_favorited_by_username(
        username,
        offset,
        limit_per_page,
        session_id
      )

    {:noreply, update_articles(socket, articles)}
  end

  def handle_info(
        {:get_articles_by_username, username, offset, limit_per_page, session_id},
        socket
      ) do
    articles = Datastore.get_articles_by_username(username, offset, limit_per_page, session_id)

    {:noreply, update_articles(socket, articles)}
  end

  defp update_articles(socket, articles) do
    pages = calc_pages(articles["articlesCount"], @limit_per_page)

    socket
    |> assign(articles: articles["articles"])
    |> assign(pages: pages)
  end

  def handle_info({:list_tags, session_id}, socket) do
    tags = Datastore.list_tags(session_id)

    {:noreply, assign(socket, tags: tags)}
  end

  def handle_info({:get_article_by_slug, slug, session_id}, socket) do
    article = Datastore.get_article_by_slug(slug, session_id)

    if article do
      send(self(), {:get_comments_from_one_article, slug, session_id})

      comments = []

      socket =
        socket
        |> assign(article: article)
        |> assign(comments: comments)
        |> assign(submit: "create_comment")

      {:noreply, socket}
    else
      {:noreply, push_redirect(socket, to: Routes.main_path(socket, :home))}
    end
  end

  def handle_info({:get_comments_from_one_article, slug, session_id}, socket) do
    comments = Datastore.get_comments_from_one_article(slug, session_id)

    socket =
      socket
      |> assign(comments: comments)

    {:noreply, socket}
  end

  # @impl true
  # def handle_info(:articles_update, socket) do
  #   # update feed because of only update current visible stuff not the "unused" articles in another feed
  #   {:noreply, update_feed(socket)}
  # end

  # def handle_info(:tags_update, socket) do
  #   {:noreply, update_tags(socket)}
  # end
end
