module Api
  module V1
    class PostsController < BaseController
      def index
        posts = Post.includes(:user, :community)

        if params[:q].present?
          q = "%#{params[:q]}%"
          posts = posts.where("title LIKE :q OR body LIKE :q", q: q)
        end

        case params[:filter]
        when "subscribed"
          ids = current_user.subscribed_communities.pluck(:id)
          posts = posts.where(community_id: ids)
        when "local"
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

        render json: posts.map { |p| serialize_post(p) }
      end

      def show
        post = Post.includes(comments: [:user]).includes(:user, :community).find(params[:id])
        comments = post.comments.includes(:user)

        comments =
          case params[:comments_sort]
          when "old" then comments.oldest_first
          else comments.newest_first
          end

        render json: { post: serialize_post(post), comments: comments.map { |c| serialize_comment(c) } }
      end

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

      def serialize_post(post)
        {
          id: post.id,
          title: post.title,
          url: post.url,
          body: post.body,
          community_id: post.community_id,
          user_id: post.user_id,
          score: post.score,
          image_url: attachment_url(post.image),
          created_at: post.created_at,
          updated_at: post.updated_at,
          user: { id: post.user.id, username: post.user.username, name: post.user.name, avatar_url: post.user.avatar_url },
          community: { id: post.community.id, slug: post.community.slug, name: post.community.name }
        }
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
