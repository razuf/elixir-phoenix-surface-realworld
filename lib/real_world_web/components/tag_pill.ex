defmodule RealWorldWeb.TagPill do
  use Surface.Component

  def render(assigns) do
    ~H"""
    <li class="tag-default tag-pill tag-outline">
      <slot/>
    </li>
    """
  end
end
