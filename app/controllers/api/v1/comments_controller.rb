module Api
  module V1
    class CommentsController < BaseController
      # BaseController ya autentica todas las acciones

      # GET /api/v1/comments (Feed Global)
      def index
        comments = Comment.includes(:user, :post).order(created_at: :desc).limit(50)
        saved_ids = current_user.saved_comments.pluck(:comment_id)

        render json: {
          comments: comments.map { |c| serialize_comment_for_feed(c, is_saved: saved_ids.include?(c.id)) }
        }
      end

      # POST /api/v1/comments/:id/save
      def save
        # Verificamos existencia (lanza 404 automático si falla)
        Comment.find(params[:id])

        saved = SavedComment.find_or_create_by(user: current_user, comment_id: params[:id])

        if saved.persisted?
          render json: { success: true }
        else
          render_unprocessable(saved)
        end
      end

      # DELETE /api/v1/comments/:id/save
      def unsave
        saved = SavedComment.find_by(user: current_user, comment_id: params[:id])

        if saved
          saved.destroy
          head :no_content
        else
          render json: { error: "not_found", message: "Comment was not saved" }, status: :not_found
        end
      end

      # --- Métodos normales ---

      def create
        post = Post.find(params[:post_id])
        comment = post.comments.new(comment_params)
        comment.user = current_user

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

      def serialize_comment(comment, is_saved: false)
        {
          id: comment.id,
          body: comment.body,
          post_id: comment.post_id,
          user_id: comment.user_id,
          parent_id: comment.parent_id,
          score: comment.score,
          is_saved: is_saved,
          created_at: comment.created_at,
          updated_at: comment.updated_at,
          user: {
            id: comment.user.id,
            username: comment.user.username,
            name: comment.user.name,
            avatar_url: comment.user.avatar_url
          }
        }
      end

      # Helper especial para el feed: Incluye info del Post
      def serialize_comment_for_feed(comment, is_saved: false)
        serialize_comment(comment, is_saved: is_saved).merge({
          post_title: comment.post&.title,
          post_community: comment.post&.community&.slug
        })
      end
    end
  end
end