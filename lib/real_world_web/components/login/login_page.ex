defmodule RealWorldWeb.LoginPage do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias RealWorldWeb.FormErrorList
  alias RealWorldWeb.LoginForm
  alias Surface.Components.LivePatch

  property(changeset, :changeset)
  property(submit, :event)
  property(form, :string, default: "form")

  @impl true
  def render(assigns) do
    ~H"""
    <div class="auth-page">
      <div class="container page">
        <div class="row">
          <div class="col-md-6 offset-md-3 col-xs-12">
            <h1 class="text-xs-center">Sign in</h1>
            <p class="text-xs-center">

              <LivePatch to={{Routes.main_path(@socket, :register)}}>
              Need an account?
              </LivePatch>

            </p>

              <FormErrorList changeset={{ @changeset }} />

              <LoginForm changeset={{ @changeset }} form={{@form}} submit={{ @submit }}/>

          </div>
        </div>
      </div>
    </div>
    """
  end
end
