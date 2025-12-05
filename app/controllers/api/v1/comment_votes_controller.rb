module Api
  module V1
    class CommentVotesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_comment
      before_action :set_vote, only: [:update, :destroy]

      # POST /api/v1/comments/:comment_id/vote
      def create
        if @comment.votes.exists?(user: current_user)
          return render json: { error: 'Vote already exists. Use PUT to update.' }, status: :conflict
        end

        @vote = @comment.votes.build(vote_params)
        @vote.user = current_user

        if @vote.save
          render_vote_with_score(:created)
        else
          render json: @vote.errors, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/comments/:comment_id/vote
      def update
        return render json: { error: 'Vote not found. Use POST to create.' }, status: :not_found unless @vote

        if @vote.update(vote_params)
          render_vote_with_score(:ok)
        else
          render json: @vote.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/comments/:comment_id/vote
      def destroy
        return render json: { error: 'Vote not found' }, status: :not_found unless @vote

        @vote.destroy
        head :no_content
      end

      private

      def set_comment
        @comment = Comment.find(params[:comment_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Comment not found' }, status: :not_found
      end

      def set_vote
        @vote = @comment.votes.find_by(user: current_user)
      end

      def vote_params
        params.require(:vote).permit(:value)
      end

      def render_vote_with_score(status)
        current_score = @comment.votes.sum(:value)
        render json: @vote.as_json.merge(score: current_score), status: status
      end
    end
  end
end