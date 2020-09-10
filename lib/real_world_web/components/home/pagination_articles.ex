defmodule RealWorldWeb.PaginationArticles do
  use Surface.Component
  use RealWorldWeb, :surface_view_helpers
  alias Surface.Components.LivePatch

  property(active_page, :integer, required: true)
  property(pages, :integer, required: true)
  property(url, :string, required: true)

  def render(assigns) do
    ~H"""
    <list-pagination :if={{ @pages > 1 }}><nav>
      <ul class="pagination">
        <li class={{ active_class(page, @active_page) }} :for={{ page <- 1..@pages, page > 0 }}>

          <LivePatch class={{ "page-link"}} label={{ page }} to={{ page_href(@url, page) }}/>

        </li>
      </ul>
    </nav>
    </list-pagination>
    """
  end
end
