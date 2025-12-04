module Api
  module V1
    class VotesController < BaseController
      ALLOWED_TYPES = %w[Post Comment].freeze
      ALLOWED_VALUES = [1, -1].freeze

      def create
        type = (params[:type] || params[:votable_type]).to_s
        id = params[:id] || params[:votable_id]
        value = (params[:value] || 1).to_i

        return render json: { error: "bad_request" }, status: :bad_request if type.blank? || id.blank?
        return render json: { error: "bad_request" }, status: :bad_request unless ALLOWED_TYPES.include?(type)
        return render json: { error: "bad_request" }, status: :bad_request unless ALLOWED_VALUES.include?(value)

        votable = type.constantize.find(id)
        vote = Vote.find_by(user: current_user, votable: votable)

        current_value =
          if vote&.value == value
            vote.destroy
            0
          elsif vote
            vote.update!(value: value)
            value
          else
            Vote.create!(user: current_user, votable: votable, value: value)
            value
          end

        render json: {
          votable_type: type,
          votable_id: votable.id,
          upvoted: current_value == 1,
          downvoted: current_value == -1,
          vote_value: current_value,
          score: votable.score
        }
      end
    end
  end
end
