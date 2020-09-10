defmodule RealWorldWeb.FormErrorList do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers

  property(changeset, :changeset)

  def render(assigns) do
    ~H"""
    <ul class="error-messages" :if={{ @changeset }}>
      <li :for={{ {error, validation} <- @changeset.errors }}>
         {{ error }} {{ flatten_error_message(validation) }}
      </li>
    </ul>
    """
  end
end
