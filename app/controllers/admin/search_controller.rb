module Admin
  class SearchController < AdminController
    def index
      if params[:q].present?
        @results = Search::User.search_documents(params[:q])
      else
        @results = Search::User.search_documents('*')
      end
    rescue StandardError => e
      @results = []
      @error = e
    end
  end
end
