module ApplicationHelper
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
