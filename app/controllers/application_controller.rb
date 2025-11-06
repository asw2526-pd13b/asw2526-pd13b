class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_or_create_by!(username: "demo") { |u| u.display_name = "Demo User" }
  end

  def require_login
    redirect_to posts_path, alert: "Necesitas estar autenticado." unless current_user
  end
end