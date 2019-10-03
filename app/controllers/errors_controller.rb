class ErrorsController < ActionController::Base
  before_action :render_page

  def error_400
  end

  def error_401
  end

  def error_403
  end

  def error_404
  end

  def error_422
  end

  def error_500
  end

  private

  def render_page
    @status = status
    render(
      layout: "error",
      status: @status,
      template: "errors/shared"
    )
  end

  def status
    request.params["action"].match(/^error_(.+)/)[1]&.to_i
  end
end
