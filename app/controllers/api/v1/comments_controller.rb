module Api
  module V1
    class CommentsController < BaseController
      def index
        post = Post.find(params[:post_id])
        comments = post.comments.includes(:user)

        case params[:sort]
        when "old"
          comments = comments.oldest_first
        else
          comments = comments.newest_first
        end

        render json: comments.map { |c| serialize_comment(c) }
      end

      def create
        post = Post.find(params[:post_id])
        comment = current_user.comments.new(comment_params.merge(post: post))

        if comment.save
          render json: { comment: serialize_comment(comment) }, status: :created
        else
          render_unprocessable(comment)
        end
      end

      def destroy
        comment = Comment.find(params[:id])
        return render_forbidden unless comment.user_id == current_user.id
        comment.destroy
        head :no_content
      end

      private

      def comment_params
        params.permit(:body, :parent_id)
      end

      def serialize_comment(comment)
        {
          id: comment.id,
          body: comment.body,
          post_id: comment.post_id,
          user_id: comment.user_id,
          parent_id: comment.parent_id,
          score: comment.score,
          created_at: comment.created_at,
          updated_at: comment.updated_at,
          user: { id: comment.user.id, username: comment.user.username, name: comment.user.name, avatar_url: comment.user.avatar_url }
        }
      end
    end
  end
end
