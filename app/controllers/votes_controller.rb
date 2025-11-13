class VotesController < ApplicationController
  before_action :require_login

  def vote
    votable = find_votable
    value = params[:value].to_i  # 1 o -1

    vote = Vote.find_by(user: current_user, votable: votable)

    # === LÓGICA ESPECIAL PARA MÍNIMO 0 ===

    if value == 1
      # UPVOTE
      if vote&.value == 1
        # Si ya tiene upvote → quitarlo (1 → 0)
        vote.destroy
      else
        # Añadir upvote (o cambiar desde 0)
        Vote.where(user: current_user, votable: votable).destroy_all
        Vote.create(user: current_user, votable: votable, value: 1)
      end

    elsif value == -1
      # DOWNVOTE → LO INTERPRETAMOS COMO "QUITAR UPVOTE"
      vote&.destroy
      # Y NO CREAMOS voto -1, porque no permites negativos
    end

    redirect_back fallback_location: posts_path
  end

  private

  def find_votable
    params[:type].constantize.find(params[:id])
  end
end