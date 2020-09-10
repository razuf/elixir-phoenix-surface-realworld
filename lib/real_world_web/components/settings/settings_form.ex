defmodule RealWorldWeb.SettingsForm do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.TextArea
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
        <TextInput field="image" form={{@form}} class={{@input_class}} opts={{ phx_debounce: "1000", placeholder: "URL of profile picture", value: get_field(@changeset, :image) }}/>
      </Field>
      <Field name="" class="form-group">
        <TextInput field="username" form={{@form}} class={{@input_class}} opts={{ phx_debounce: "1000", placeholder: "Your Name", value: get_field(@changeset, :username) }}/>
      </Field>
      <Field name="" class="form-group">
        <TextArea field="bio" form={{@form}} class={{@input_class}} opts={{ phx_debounce: "1000", rows: "8", placeholder: "Short bio about you", value: get_field(@changeset, :bio) }}/>
      </Field>
      <Field name="" class="form-group">
        <TextInput field="email" form={{@form}} class={{@input_class}} opts={{ phx_debounce: "1000", placeholder: "Email", value: get_field(@changeset, :email) }}/>
      </Field>
      <Field name="" class="form-group">
        <PasswordInput field="password" form={{@form}} class={{@input_class}} opts={{ phx_debounce: "1000", placeholder: "Password" }}/>
      </Field>
      <Button class="btn btn-lg btn-primary pull-xs-right" type="submit">Update Settings</Button>
    </Form>
    """
  end
end
