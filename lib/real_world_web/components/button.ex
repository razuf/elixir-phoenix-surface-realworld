defmodule RealWorldWeb.Button do
  use Surface.Component

  property(click, :event)
  property(value, :string)
  property(type, :string)
  property(class, :string)
  property(style, :string)

  def render(assigns) do
    ~H"""
    <button
    :on-phx-click={{ @click }}
    value={{ @value }}
    type={{ @type }}
    class={{ @class }}
    style="{{ @style }}">
    <slot/>
    </button>
    """
  end
end
