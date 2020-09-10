defmodule RealWorldWeb.SettingsPage do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  alias RealWorldWeb.FormErrorList
  alias RealWorldWeb.SettingsForm

  property(changeset, :changeset)
  property(change, :event)
  property(submit, :event)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="settings-page">
      <div class="container page">
        <div class="row">

          <div class="col-md-6 offset-md-3 col-xs-12">
            <h1 class="text-xs-center">Your Settings</h1>

            <FormErrorList changeset={{ @changeset }} />

            <SettingsForm
            changeset={{ @changeset }}
            change={{ @change }}
            submit={{ @submit }}/>

          </div>
        </div>
      </div>
    </div>
    """
  end
end
