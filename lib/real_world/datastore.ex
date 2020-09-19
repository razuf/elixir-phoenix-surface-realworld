defmodule RealWorld.Datastore do
  @moduledoc """
  The Datastore.
  """
  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias RealWorld.Api
  alias RealWorld.Repo
  alias RealWorld.User
  alias RealWorld.Article
  alias RealWorld.Comment
  alias RealWorld.Helpers

  alias RealWorld.Backend

  ### Backend

  def default_backend() do
    %Backend{}
  end

  def change_backend() do
    Backend.changeset(default_backend())
  end

  def validate_backend(form_params) do
    changeset = Backend.changeset_from_form(default_backend(), form_params)

    cond do
      changeset.valid? ->
        :ok

      true ->
        {:error, changeset}
    end
  end

  ### User

  def default_user() do
    %User{}
  end

  def change_user() do
    User.changeset_login(default_user(), %{})
  end

  def change_user(%User{} = user, attrs) do
    User.changeset(user, attrs)
  end

  def change_user(attrs) do
    User.changeset(default_user(), attrs)
  end

  def get_user_by_session_id(session_id) do
    Repo.get_by(User, %{:session_id => session_id})
  end

  def get_token_by_session_id(session_id) do
    session_id = session_id || ""
    user = Repo.get_by(User, %{:session_id => session_id})
    (user && user.token) || nil
  end

  def auth_user(form_params) do
    # POST /api/users/login
    # Example request body:
    # {
    #   "user":{
    #     "email": "jake@jake.jake",
    #     "password": "jakejake"
    #   }
    # }
    changeset = User.changeset_auth(default_user(), form_params)

    cond do
      changeset.valid? ->
        user_attrs = %{
          email: changeset.changes.email,
          password: changeset.changes.password
        }

        request_body = %{"user" => user_attrs}
        result = Api.server_post("/users/login", request_body)

        case result do
          %{"user" => user} ->
            {:ok, user}

          %{"errors" => errors} ->
            changeset =
              changeset
              |> Helpers.add_errors_to_changeset(errors)

            {:error, changeset}

          error ->
            changeset =
              changeset
              |> Helpers.add_errors_to_changeset(inspect(error))

            {:error, changeset}
        end

      true ->
        {:error, changeset}
    end
  end

  def login(user_attrs, session_id) do
    user_attrs =
      user_attrs
      |> Map.merge(%{"session_id" => session_id})
      |> Map.merge(%{"password" => "dummypassword"})

    change_user(user_attrs)
    |> Repo.insert()
  end

  def logout(current_user) do
    frontend_user = get_user_by_session_id(current_user.session_id)

    Repo.delete(frontend_user)
  end

  def register_user(user_attrs, session_id) do
    # POST /api/users
    # Example request body:
    # {
    #   "user":{
    #     "username": "Jacob",
    #     "email": "jake@jake.jake",
    #     "password": "jakejake"
    #   }
    # }

    changeset = change_user(user_attrs)

    if changeset.valid? do
      request_body = %{"user" => changeset.changes}
      result = Api.server_post("/users", request_body, session_id)

      case result do
        %{"user" => server_user} ->
          {:ok, server_user}

        %{"errors" => errors} ->
          changeset =
            changeset
            |> Helpers.add_errors_to_changeset(errors)

          {:error, changeset}

        _ ->
          changeset =
            changeset
            |> add_error(:user, "register error")

          {:error, changeset}
      end
    else
      {:error, changeset}
    end
  end

  def update_user(user_attrs, session_id) do
    # PUT /api/user
    # Example request body:
    # {
    #   "user":{
    #     "email": "jake@jake.jake",
    #     "bio": "I like to skateboard",
    #     "image": "https://i.stack.imgur.com/xHWG8.jpg"
    #   }
    # }

    changeset = change_user(user_attrs)

    if changeset.valid? do
      request_body = %{"user" => changeset.changes}
      result = Api.server_put("/user", request_body, session_id)

      case result do
        %{"user" => backend_user} ->
          frontend_user = Map.merge(backend_user, %{"password" => "dummypassword"})

          session_id
          |> get_user_by_session_id()
          |> change_user(frontend_user)
          |> Repo.update()

        %{"errors" => errors} ->
          changeset =
            changeset
            |> Helpers.add_errors_to_changeset(errors)

          {:error, changeset}

        _ ->
          changeset =
            changeset
            |> add_error(:user, "update error")

          {:error, changeset}
      end
    else
      {:error, changeset}
    end
  end

  def toggle_following_user(:unfollowing, username, session_id) do
    # DELETE /api/profiles/:username/follow

    result = Api.server_delete("/profiles/#{username}/follow", session_id)

    case result do
      %{"profile" => profile} ->
        profile

      _ ->
        :error
    end
  end

  def toggle_following_user(:follow, username, session_id) do
    # POST /api/profiles/:username/follow

    result = Api.server_post("/profiles/#{username}/follow", "", session_id)

    case result do
      %{"profile" => profile} ->
        profile

      _ ->
        :error
    end
  end

  ### Article

  def default_article() do
    %Article{}
  end

  def change_article(attrs) do
    Article.changeset_from_article(default_article(), attrs)
  end

  def change_new_article() do
    Article.changeset(%Article{})
  end

  def get_article_by_slug(slug, session_id) do
    result = Api.server_get("/articles/#{slug}", session_id)

    case result do
      %{"article" => article} ->
        article

      _ ->
        nil
    end
  end

  def create_article(form_params, session_id) do
    # POST /api/articles
    # Example request body:
    # {
    #   "article": {
    #     "title": "How to train your dragon",
    #     "description": "Ever wonder how?",
    #     "body": "You have to believe",
    #     "tagList": ["reactjs", "angularjs", "dragons"]
    #   }
    # }

    changeset = Article.changeset_from_form(default_article(), form_params)

    if changeset.valid? do
      request_body = %{"article" => changeset.changes}
      result = Api.server_post("/articles", request_body, session_id)

      case result do
        %{"article" => article} ->
          {:ok, article}

        %{"error" => error} ->
          changeset =
            changeset
            |> add_error(:article, "update error: #{error}")

          {:error, changeset}

        _ ->
          changeset =
            changeset
            |> add_error(:article, "update error")

          {:error, changeset}
      end
    else
      {:error, changeset}
    end
  end

  def update_article(form_params, session_id) do
    # PUT /api/articles/:slug
    # Example request body:
    # {
    #   "article": {
    #     "title": "Did you train your dragon?"
    #   }
    # }

    changeset = Article.changeset_from_form(default_article(), form_params)

    if changeset.valid? do
      slug = form_params["slug"]
      request_body = %{"article" => changeset.changes}
      result = Api.server_put("/articles/#{slug}", request_body, session_id)

      case result do
        %{"article" => article} ->
          {:ok, article}

        %{"error" => error} ->
          changeset =
            changeset
            |> add_error(:article, "update error: #{error}")

          {:error, changeset}

        _ ->
          changeset =
            changeset
            |> add_error(:article, "update error")

          {:error, changeset}
      end
    else
      {:error, changeset}
    end
  end

  def delete_article(article, session_id) do
    # DELETE /api/articles/:slug

    slug = article["slug"]
    result = Api.server_delete("/articles/#{slug}", session_id)

    case result do
      %{"error" => _error} ->
        :error

      _empty_result ->
        :ok
    end
  end

  ### favorited_article

  def toggle_favorited_article(:unfavorite, slug, session_id) do
    # DELETE /api/articles/:slug/favorite

    result = Api.server_delete("/articles/#{slug}/favorite", session_id)
    # result["article"]

    case result do
      %{"article" => article} ->
        {:ok, article}

      %{"error" => error} ->
        {:error, error}
    end
  end

  def toggle_favorited_article(:favorite, slug, session_id) do
    # POST /api/articles/:slug/favorite

    result = Api.server_post("/articles/#{slug}/favorite", "", session_id)
    # result["article"]
    case result do
      %{"article" => article} ->
        {:ok, article}

      %{"error" => error} ->
        {:error, error}
    end
  end

  ### articles

  def list_articles(offset, limit_per_page, session_id) do
    result = Api.server_get("/articles?limit=#{limit_per_page}&offset=#{offset}", session_id)
    result_handler_articles(result)
  end

  def feed_articles(offset, limit_per_page, session_id) do
    result = Api.server_get("/articles/feed?limit=#{limit_per_page}&offset=#{offset}", session_id)
    result_handler_articles(result)
  end

  def get_articles_by_tag(tag, offset, limit_per_page, session_id) do
    result =
      Api.server_get(
        "/articles?tag=#{tag}&limit=#{limit_per_page}&offset=#{offset}",
        session_id
      )

    result_handler_articles(result)
  end

  def get_articles_by_username(username, offset, limit_per_page, session_id) do
    result =
      Api.server_get(
        "/articles?author=#{username}&limit=#{limit_per_page}&offset=#{offset}",
        session_id
      )

    result_handler_articles(result)
  end

  def get_articles_favorited_by_username(username, offset, limit_per_page, session_id) do
    result =
      Api.server_get(
        "/articles?favorited=#{username}&limit=#{limit_per_page}&offset=#{offset}",
        session_id
      )

    result_handler_articles(result)
  end

  defp result_handler_articles(result) do
    case result do
      %{"articles" => articles, "articlesCount" => articlesCount} ->
        %{"articles" => articles, "articlesCount" => articlesCount}

      result ->
        %{"articles" => [], "articlesCount" => 0}
    end
  end

  ### Comment

  def default_comment() do
    %Comment{}
  end

  def change_new_comment() do
    Comment.changeset(default_comment())
  end

  def get_comments_from_one_article(slug, session_id) do
    result = Api.server_get("/articles/#{slug}/comments", session_id)

    case result do
      %{"comments" => comments} ->
        comments

      _ ->
        []
    end
  end

  def create_comment_for_slug(slug, form_params, session_id) do
    # POST /api/articles/:slug/comments

    changeset = Comment.changeset_from_form(default_comment(), form_params)

    if changeset.valid? do
      request_body = %{"comment" => form_params}
      result = Api.server_post("/articles/#{slug}/comments", request_body, session_id)

      case result do
        %{"comment" => comment} ->
          {:ok, comment}

        %{"errors" => errors} ->
          changeset =
            changeset
            |> Helpers.add_errors_to_changeset(errors)

          {:error, changeset}

        _ ->
          changeset =
            changeset
            |> add_error(:comment, "create error")

          {:error, changeset}
      end
    else
      {:error, changeset}
    end
  end

  def delete_comment_by_id(article, id, session_id) do
    # DELETE /api/articles/:slug/comments/:id

    slug = article["slug"]
    result = Api.server_delete("/articles/#{slug}/comments/#{id}", session_id)

    case result do
      %{"error" => _error} ->
        :error

      %{"errors" => _errors} ->
        :error

      _result ->
        :ok
    end
  end

  ### profile

  def get_profile_by_username(username, session_id) do
    result = Api.server_get("/profiles/#{username}", session_id)

    case result do
      %{"profile" => profile} ->
        profile

      _ ->
        nil
    end
  end

  ### tags

  def list_tags(session_id \\ "") do
    result = Api.server_get("/tags", session_id)

    case result do
      %{"tags" => tags} ->
        tags

      _ ->
        []
    end
  end
end
