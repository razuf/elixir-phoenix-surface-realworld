defmodule RealWorldWeb.CommentForm do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias Surface.Components.Form
  alias Surface.Components.Form.TextArea
  alias RealWorldWeb.Button

  property(changeset, :changeset)
  property(submit, :event)
  property(input_class, :string, default: "form-control form-control-lg")
  property(form, :string, default: "form")

  property(author, :map)

  def render(assigns) do
    ~H"""
    <Form for={{ @changeset }} submit={{ @submit }} opts={{ class: "card comment-form"}}>
      <div class="card-block">
        <TextArea field="body" form={{@form}} class={{@input_class}} opts={{ rows: "3", placeholder: "Write a comment...", value: get_field(@changeset, :body) }}/>
      </div>
      <div class="card-footer">
      <img src={{ get_user_image(@author.image) }} class="comment-author-img" loading="lazy"/>
      <Button class="btn btn-sm btn-primary" type="submit">
      Post Comment</Button>
      </div>
    </Form>
    """
  end
end
