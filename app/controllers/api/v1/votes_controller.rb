module Api
  module V1
    class VotesController < BaseController
      before_action :authenticate_api_key!

      # POST /api/v1/votes
      # Params: { votable_type: "Post", votable_id: 1, value: 1 }
      def create
        votable = find_votable
        value = params[:value].to_i  # 1 o -1

        unless votable
          render json: { error: 'Votable not found' }, status: :not_found
          return
        end

        unless [1, -1].include?(value)
          render json: { error: 'Value must be 1 or -1' }, status: :unprocessable_entity
          return
        end

        vote = Vote.find_by(user: current_api_user, votable: votable)

        # Lògica de vot (mínim 0)
        if value == 1
          # UPVOTE
          if vote&.value == 1
            # Si ja té upvote → treure'l (1 → 0)
            vote.destroy
            message = 'Vote removed'
          else
            # Afegir upvote (o canviar des de 0)
            Vote.where(user: current_api_user, votable: votable).destroy_all
            Vote.create!(user: current_api_user, votable: votable, value: 1)
            message = 'Upvoted'
          end
        elsif value == -1
          # DOWNVOTE → TREURE UPVOTE
          if vote
            vote.destroy
            message = 'Vote removed'
          else
            message = 'No vote to remove'
          end
        end

        render json: {
          message: message,
          vote_count: votable.votes.sum(:value)
        }, status: :ok

      rescue ActiveRecord::RecordInvalid => e
        render json: {
          error: 'Validation failed',
          details: e.record.errors.full_messages
        }, status: :unprocessable_entity
      end

      # DELETE /api/v1/votes
      # Params: { votable_type: "Post", votable_id: 1 }
      def destroy
        votable = find_votable

        unless votable
          render json: { error: 'Votable not found' }, status: :not_found
          return
        end

        vote = Vote.find_by(user: current_api_user, votable: votable)

        if vote
          vote.destroy
          render json: {
            message: 'Vote removed',
            vote_count: votable.votes.sum(:value)
          }, status: :ok
        else
          render json: { error: 'No vote found' }, status: :not_found
        end
      end

      private

      def find_votable
        votable_type = params[:votable_type]
        votable_id = params[:votable_id]

        return nil unless votable_type.present? && votable_id.present?

        # Validar que sigui un tipus vàlid
        unless ['Post', 'Comment'].include?(votable_type)
          return nil
        end

        votable_type.constantize.find_by(id: votable_id)
      end
    end
  end
end