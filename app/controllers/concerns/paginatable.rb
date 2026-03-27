module Paginatable
  extend ActiveSupport::Concern

  Pagination = Struct.new(:current_page, :per_page, :total_count, :total_pages, keyword_init: true) do
    def previous_page
      current_page > 1 ? current_page - 1 : nil
    end

    def next_page
      current_page < total_pages ? current_page + 1 : nil
    end

    def first_item_number
      return 0 if total_count.zero?

      ((current_page - 1) * per_page) + 1
    end

    def last_item_number
      return 0 if total_count.zero?

      [current_page * per_page, total_count].min
    end
  end

  private

  def paginate_scope(scope, per_page: 10)
    total_count = scope.except(:limit, :offset, :order, :includes, :preload, :eager_load).count(:all)
    total_pages = [(total_count.to_f / per_page).ceil, 1].max
    current_page = total_count.zero? ? 1 : [requested_page, total_pages].min

    records = scope.limit(per_page).offset((current_page - 1) * per_page)

    [
      records,
      Pagination.new(
        current_page: current_page,
        per_page: per_page,
        total_count: total_count,
        total_pages: total_pages
      )
    ]
  end

  def requested_page
    page = params[:page].to_i
    page.positive? ? page : 1
  end
end
