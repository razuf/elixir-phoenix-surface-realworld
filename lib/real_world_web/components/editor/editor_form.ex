defmodule RealWorldWeb.EditorForm do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.TextArea
  alias RealWorldWeb.Button

  property(changeset, :changeset)
  property(submit, :event)
  property(input_class, :string, default: "form-control form-control-lg")
  property(form, :string, default: "form")

  def render(assigns) do
    ~H"""
    <Form for={{ @changeset }} submit={{ @submit }}>
      <Field name="" class="form-group">
        <TextInput field="title" form={{@form}} class={{@input_class}} opts={{ placeholder: "Article Title", value: get_field(@changeset, :title) }}/>
      </Field>
      <Field name="" class="form-group">
        <TextInput field="description" form={{@form}} class={{@input_class}} opts={{ placeholder: "What's this article about?", value: get_field(@changeset, :description) }}/>
      </Field>
      <Field name="" class="form-group">
        <TextArea field="body" form={{@form}} class={{@input_class}} opts={{ rows: "8", placeholder: "Write your article (in markdown)", value: get_field(@changeset, :body) }}/>
      </Field>
      <Field name="" class="form-group">
        <TextInput field="tag_list_string" form={{@form}} class={{@input_class}} opts={{ placeholder: "Enter tags", value: get_field(@changeset, :tag_list_string) }}/>
        <div class="tag-list"></div>
      </Field>
      <Button class="btn btn-lg btn-primary pull-xs-right" type="submit">
      Publish Article</Button>
    </Form>
    """
  end
end
