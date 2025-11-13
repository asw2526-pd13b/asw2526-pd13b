class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  # Devise ja proporciona current_user i user_signed_in?
  # No cal definir-los aquí

  # Descomenteu si voleu requerir login a TOTES les pàgines:
  # before_action :authenticate_user!

  private

  def require_login
    redirect_to root_path, alert: "Necessites estar autenticat." unless user_signed_in?
  end
end