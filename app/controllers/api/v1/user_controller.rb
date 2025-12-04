module Api
  module V1
    class UsersController < BaseController
      def index
        users = User.order(created_at: :desc)
        render json: users.map { |u| serialize_user(u) }
      end

      def show
        user = User.find(params[:id])
        posts = user.posts.includes(:community).order(created_at: :desc).limit(20)
        comments = user.comments.includes(:post).order(created_at: :desc).limit(20)

        render json: {
          user: serialize_user(user),
          posts: posts.map { |p| serialize_post_summary(p) },
          comments: comments.map { |c| serialize_comment_summary(c) }
        }
      end

      def update
        user = User.find(params[:id])
        return render_forbidden unless user.id == current_user.id

        if user.update(user_params)
          render json: { user: serialize_user(user) }
        else
          render_unprocessable(user)
        end
      end

      private

      def user_params
        params.permit(:display_name, :bio, :banner_url)
      end

      def serialize_user(user)
        {
          id: user.id,
          username: user.username,
          display_name: user.display_name,
          name: user.name,
          email: user.email,
          avatar_url: user.avatar_url,
          banner_url: user.banner_url,
          bio: user.bio,
          posts_count: user.posts_count,
          comments_count: user.comments_count,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end

      def serialize_post_summary(post)
        {
          id: post.id,
          title: post.title,
          url: post.url,
          body: post.body,
          score: post.score,
          community: { id: post.community_id, slug: post.community.slug, name: post.community.name },
          created_at: post.created_at
        }
      end

      def serialize_comment_summary(comment)
        {
          id: comment.id,
          body: comment.body,
          post: { id: comment.post_id, title: comment.post.title },
          parent_id: comment.parent_id,
          score: comment.score,
          created_at: comment.created_at
        }
      end
    end
  end
end
