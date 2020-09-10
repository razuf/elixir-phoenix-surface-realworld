defmodule RealWorldWeb.RegisterForm do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.PasswordInput
  alias RealWorldWeb.Button

  property(changeset, :changeset)
  property(submit, :event)
  property(change, :event)
  property(input_class, :string, default: "form-control form-control-lg")
  property(form, :string, default: "form")

  def render(assigns) do
    ~H"""
    <Form for={{ @changeset }} submit={{ @submit }} change={{ @change }}>
      <Field name="" class="form-group">
        <TextInput form={{@form}} field="username" class={{@input_class}} opts={{ phx_debounce: "1000", placeholder: "Your Name", value: get_field(@changeset, :username) }}/>
      </Field>
      <Field name="" class="form-group">
        <TextInput form={{@form}} field="email" class={{@input_class}} opts={{ phx_debounce: "1000", placeholder: "Email", value: get_field(@changeset, :email) }}/>
      </Field>
      <Field name="" class="form-group">
        <PasswordInput form={{@form}} field="password" class={{@input_class}} opts={{ phx_debounce: "1000", placeholder: "Password", value: get_field(@changeset, :password) }}/>
      </Field>
      <Button class="btn btn-lg btn-primary pull-xs-right" type="submit">
      Sign up</Button>
    </Form>
    """
  end
end
