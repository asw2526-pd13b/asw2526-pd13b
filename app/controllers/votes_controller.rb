class VotesController < ApplicationController
  before_action :require_login

  def vote
    votable = find_votable
    incoming_value = params[:value].to_i # 1 o -1

    # Buscamos si ya existe un voto del usuario
    vote = Vote.find_by(user: current_user, votable: votable)

    if vote
      if vote.value == incoming_value
        # Si vota lo mismo que ya tenía -> TOGGLE (borrar voto)
        vote.destroy
      else
        # Si cambia de opinión (de +1 a -1 o viceversa) -> UPDATE
        vote.update(value: incoming_value)
      end
    else
      # Si no tenía voto -> CREATE
      Vote.create(user: current_user, votable: votable, value: incoming_value)
    end

    redirect_back fallback_location: posts_path
  end

  private

  def find_votable
    params[:type].constantize.find(params[:id])
  end

  # Si no usas Devise helper 'authenticate_user!', define esto
  # Si usas Devise, cámbialo por 'before_action :authenticate_user!'
  def require_login
    unless signed_in?
      flash[:error] = "Debes iniciar sesión para votar"
      redirect_to new_user_session_path
    end
  end

  # Helper simple para ver si usas Devise
  def signed_in?
    defined?(current_user) && current_user.present?
  end
end