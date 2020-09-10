defmodule RealWorldWeb.ArticlePage do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias RealWorldWeb.ArticleMeta
  alias RealWorldWeb.FormErrorList
  alias RealWorldWeb.CommentForm
  alias RealWorldWeb.CommentCard
  alias Surface.Components.LivePatch
  alias RealWorldWeb.TagPill

  property(current_user, :map, default: %{})
  property(article, :map)
  property(comments, :list, default: [])
  property(submit, :event)
  property(changeset, :changeset)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="article-page">
      <div class="banner">
        <div class="container">
          <h1>{{ @article["title"]}}</h1>

          <ArticleMeta article={{ @article}} current_user={{ @current_user}}/>

        </div>
      </div>
      <div class="container page">

        <div class="row article-content">
          <div class="col-md-12">
            <div class="">
              {{ raw(Earmark.as_html!(@article["body"])) }}
            </div>
            <ul class="tag-list">
              <TagPill :for={{ tag <- @article["tagList"] }}>
                {{ tag }}
              </TagPill>
            </ul>
          </div>
        </div>

        <hr />
        <div class="article-actions">

          <ArticleMeta article={{ @article}} current_user={{ @current_user}}/>

        </div>
        <div class="row">
          <div class="col-xs-12 col-md-8 offset-md-2">

            <p :if={{ not user_signed_in?(@current_user) }} style="display: inherit;">
            <LivePatch to={{Routes.main_path(@socket, :login)}}>Sign in</LivePatch>
            or
            <LivePatch to={{Routes.main_path(@socket, :register)}}>sign up</LivePatch>
            to add comments on this article.
            </p>

            <FormErrorList changeset={{ @changeset }} />

            <CommentForm
            :if={{ user_signed_in?(@current_user) }}
            changeset={{ @changeset }}
            author={{ @current_user }}
            submit={{ @submit}}/>

            <CommentCard  :for={{ comment <- @comments }}
            comment={{ comment }}
            current_user={{ @current_user}}/>

          </div>
        </div>
      </div>
    </div>
    """
  end
end
