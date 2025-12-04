class VotesController < ApplicationController
  before_action :require_login

  ALLOWED_TYPES = %w[Post Comment].freeze
  ALLOWED_VALUES = [1, -1].freeze

  def vote
    type = params[:type].to_s
    id = params[:id]
    value = params[:value].to_i

    return redirect_back fallback_location: posts_path unless ALLOWED_TYPES.include?(type)
    return redirect_back fallback_location: posts_path unless ALLOWED_VALUES.include?(value)

    votable = type.constantize.find(id)
    vote = Vote.find_by(user: current_user, votable: votable)

    if vote&.value == value
      vote.destroy
    elsif vote
      vote.update!(value: value)
    else
      Vote.create!(user: current_user, votable: votable, value: value)
    end

    redirect_back fallback_location: posts_path
  end
end
