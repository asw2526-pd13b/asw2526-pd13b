module Api
  module V1
    class VotesController < BaseController
      ALLOWED_TYPES = %w[Post Comment].freeze
      ALLOWED_VALUES = [1, -1].freeze

      def create
        type = params[:type] || params[:votable_type]
        id = params[:id] || params[:votable_id]
        value = (params[:value] || 1).to_i

        return render json: { error: "bad_request" }, status: :bad_request if type.blank? || id.blank?
        return render json: { error: "bad_request" }, status: :bad_request unless ALLOWED_TYPES.include?(type)
        return render json: { error: "bad_request" }, status: :bad_request unless ALLOWED_VALUES.include?(value)

        votable = type.constantize.find(id)
        vote = Vote.find_by(user: current_user, votable: votable)

        upvoted = false

        if value == 1
          if vote&.value == 1
            vote.destroy
            upvoted = false
          else
            if vote
              vote.update!(value: 1)
            else
              Vote.create!(user: current_user, votable: votable, value: 1)
            end
            upvoted = true
          end
        else
          vote&.destroy
          upvoted = false
        end

        render json: { votable_type: type, votable_id: votable.id, upvoted: upvoted, score: votable.score }
      end
    end
  end
end
