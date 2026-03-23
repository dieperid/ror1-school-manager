module ApplicationHelper
  def pagination_page_items(pagination)
    total_pages = pagination.total_pages
    current_page = pagination.current_page

    return (1..total_pages).to_a if total_pages <= 4

    if current_page <= 2
      [1, 2, 3, :gap, total_pages]
    elsif current_page >= total_pages - 1
      [1, :gap, total_pages - 1, total_pages]
    else
      [current_page - 1, current_page, current_page + 1, :gap, total_pages]
    end
  end

  def pagination_path_for(page_number)
    query = request.query_parameters.stringify_keys

    if page_number.to_i <= 1
      query.delete("page")
    else
      query["page"] = page_number
    end

    query_string = query.to_query
    query_string.present? ? "#{request.path}?#{query_string}" : request.path
  end
end
