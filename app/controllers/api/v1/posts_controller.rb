module Api
  module V1
    class PostsController < BaseController
      # NO hace falta 'before_action :authenticate_with_api_key!'
      # porque BaseController ya lo ejecuta para todas las acciones.

      def index
        posts = Post.includes(:user, :community)

        if params[:q].present?
          q = "%#{params[:q]}%"
          posts = posts.where("title LIKE :q OR body LIKE :q", q: q)
        end

        if params[:filter] == "subscribed"
           ids = current_user.subscribed_communities.pluck(:id)
           posts = posts.where(community_id: ids)
        end

        case params[:sort]
        when "old"
          posts = posts.order(created_at: :asc)
        when "comments"
          posts = posts.left_joins(:comments).group(:id).order("COUNT(comments.id) DESC")
        when "top", "popular"
          score_sql = "CASE WHEN COALESCE(SUM(votes.value), 0) < 0 THEN 0 ELSE COALESCE(SUM(votes.value), 0) END"
          posts = posts.left_joins(:votes).group("posts.id").order(Arel.sql("#{score_sql} DESC, posts.created_at DESC"))
        else
          posts = posts.order(created_at: :desc)
        end

        # Optimizamos: Sacamos todos los IDs guardados por el usuario
        saved_ids = current_user.saved_posts.pluck(:post_id)

        render json: posts.map { |p| serialize_post(p, is_saved: saved_ids.include?(p.id)) }
      end

      def show
        # Si el ID no existe, BaseController lanza 404 automáticamente gracias a rescue_from
        post = Post.includes(comments: [:user]).includes(:user, :community).find(params[:id])

        comments_scope = post.comments.includes(:user)
        comments_scope = params[:comments_sort] == "old" ? comments_scope.order(created_at: :asc) : comments_scope.order(created_at: :desc)

        post_is_saved = SavedPost.exists?(user: current_user, post: post)

        # Optimizamos verificación de comentarios guardados
        saved_comment_ids = current_user.saved_comments.where(comment_id: comments_scope.pluck(:id)).pluck(:comment_id)

        render json: {
          post: serialize_post(post, is_saved: post_is_saved),
          comments: comments_scope.map { |c| serialize_comment(c, is_saved: saved_comment_ids.include?(c.id)) }
        }
      end

      # --- SAVE / UNSAVE ---

      def save
        # Validamos que el post exista (lanza 404 si no existe, capturado por BaseController)
        Post.find(params[:id])

        saved = SavedPost.find_or_create_by(user: current_user, post_id: params[:id])

        if saved.persisted?
          render json: { success: true }
        else
          render_unprocessable(saved)
        end
      end

      def unsave
        saved = SavedPost.find_by(user: current_user, post_id: params[:id])

        if saved
          saved.destroy
          head :no_content
        else
          # Si no estaba guardado, devolvemos 404
          render json: { error: "not_found", message: "Post was not saved" }, status: :not_found
        end
      end

      # --- CRUD ESTÁNDAR ---

      def create
        post = current_user.posts.new(post_params)
        if post.save
          render json: { post: serialize_post(post) }, status: :created
        else
          render_unprocessable(post)
        end
      end

      def update
        post = Post.find(params[:id])
        return render_forbidden unless post.user_id == current_user.id

        if post.update(post_params)
          render json: { post: serialize_post(post) }
        else
          render_unprocessable(post)
        end
      end

      def destroy
        post = Post.find(params[:id])
        return render_forbidden unless post.user_id == current_user.id
        post.destroy
        head :no_content
      end

      private

      def post_params
        params.permit(:title, :url, :body, :community_id, :image)
      end

      def serialize_post(post, is_saved: false)
        {
          id: post.id,
          title: post.title,
          url: post.url,
          body: post.body,
          community_id: post.community_id,
          user_id: post.user_id,
          score: post.score,
          image_url: attachment_url(post.image), # Usa el del BaseController
          is_saved: is_saved,
          created_at: post.created_at,
          updated_at: post.updated_at,
          user: {
            id: post.user.id,
            username: post.user.username,
            name: post.user.name,
            avatar_url: post.user.avatar_url
          },
          community: {
            id: post.community.id,
            slug: post.community.slug,
            name: post.community.name
          }
        }
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
    end
  end
end