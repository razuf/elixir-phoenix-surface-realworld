defmodule RealWorldWeb.LoginForm do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.PasswordInput
  alias RealWorldWeb.Button

  property(changeset, :changeset)
  property(submit, :event)
  property(input_class, :string, default: "form-control form-control-lg")
  property(form, :string, default: "form")

  @impl true
  def render(assigns) do
    ~H"""
    <Form for={{ @changeset }} submit={{ @submit }}>
      <Field name="" class="form-group">
        <TextInput field="email" form={{@form}} class={{@input_class}} opts={{ placeholder: "Email", value: get_field(@changeset, :email) }}/>
      </Field>
      <Field name="" class="form-group">
        <PasswordInput field="password" form={{@form}} class={{@input_class}} opts={{ placeholder: "Password", value: get_field(@changeset, :password) }}/>
      </Field>
      <Button class="btn btn-lg btn-primary pull-xs-right" type="submit">
      Sign in</Button>
      </Form>
    """
  end
end
