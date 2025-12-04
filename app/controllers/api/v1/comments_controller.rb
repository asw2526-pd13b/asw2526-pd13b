module Api
  module V1
    class CommentsController < BaseController
      before_action :authenticate_api_key!
      before_action :set_comment, only: [:update, :destroy]
      before_action :authorize_comment_owner!, only: [:update, :destroy]

      # POST /api/v1/posts/:post_id/comments
      def create
        @post = Post.find(params[:post_id])
        @comment = @post.comments.new(comment_params)
        @comment.user = current_api_user

        if @comment.save
          render json: comment_json(@comment), status: :created
        else
          render json: {
            error: 'Validation failed',
            details: @comment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PUT/PATCH /api/v1/comments/:id
      def update
        if @comment.update(comment_params)
          render json: comment_json(@comment)
        else
          render json: {
            error: 'Validation failed',
            details: @comment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/comments/:id
      def destroy
        @comment.destroy
        head :no_content
      end

      private

      def set_comment
        @comment = Comment.find(params[:id])
      end

      def authorize_comment_owner!
        authorize_owner!(@comment)
      end

      def comment_params
        params.require(:comment).permit(:body, :parent_id)
      end

      def comment_json(comment)
        {
          id: comment.id,
          body: comment.body,
          created_at: comment.created_at,
          updated_at: comment.updated_at,
          post_id: comment.post_id,
          parent_id: comment.parent_id,
          user: {
            id: comment.user.id,
            username: comment.user.username,
            display_name: comment.user.display_name
          }
        }
        # Afegir vot de l'usuari actual si està autenticat
        if current_api_user
          user_vote = comment.votes.find_by(user: current_api_user)
          json[:user_vote] = user_vote&.value
        end
        json
      end
    end
  end
end