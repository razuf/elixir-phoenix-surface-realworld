defmodule RealWorldWeb.EditorPage do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias RealWorldWeb.FormErrorList
  alias RealWorldWeb.EditorForm

  property(changeset, :changeset)
  property(submit, :event)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="editor-page">
      <div class="container page">
        <div class="row">
          <div class="col-md-10 offset-md-1 col-xs-12">

            <FormErrorList changeset={{ @changeset }} />

            <EditorForm
            changeset={{ @changeset }}
            submit={{ @submit }}/>

          </div>
        </div>
      </div>
    </div>
    """
  end
end
