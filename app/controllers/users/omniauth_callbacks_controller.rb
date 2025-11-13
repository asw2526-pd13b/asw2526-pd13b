class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :github

  def github
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)

    if user
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
    else
      redirect_to root_path, alert: "No se ha podido iniciar sesión con GitHub."
    end
  end

  def failure
    redirect_to root_path, alert: "Autenticación cancelada o fallida."
  end
end
