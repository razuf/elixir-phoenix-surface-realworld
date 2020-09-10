defmodule RealWorldWeb.RegisterPage do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias Surface.Components.LivePatch
  alias RealWorldWeb.FormErrorList
  alias RealWorldWeb.RegisterForm

  property(changeset, :changeset)
  property(submit, :event)
  property(change, :event)
  property(form, :string, default: "form")

  @impl true
  def render(assigns) do
    ~H"""
    <div class="auth-page">
      <div class="container page">
        <div class="row">

          <div class="col-md-6 offset-md-3 col-xs-12">
            <h1 class="text-xs-center">Sign up</h1>
            <p class="text-xs-center">

              <LivePatch to={{Routes.main_path(@socket, :login)}}>
              Have an account?
              </LivePatch>

            </p>

            <FormErrorList changeset={{ @changeset }} />

            <RegisterForm
            changeset={{ @changeset }}
            form={{@form}}
            change={{ @change }}
            submit={{ @submit }}/>

          </div>
        </div>
      </div>
    </div>
    """
  end
end
