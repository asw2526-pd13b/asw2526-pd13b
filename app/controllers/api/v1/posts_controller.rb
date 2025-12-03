module Api
  module V1
    class PostsController < BaseController
      before_action :authenticate_api_key!, except: [:index, :show]
      before_action :set_post, only: [:show, :update, :destroy]
      before_action :authorize_post_owner!, only: [:update, :destroy]

      # GET /api/v1/posts
      def index
        @posts = Post.includes(:user, :community).order(created_at: :desc)

        # Filtrar per comunitat si es proporciona
        if params[:community_id].present?
          @posts = @posts.where(community_id: params[:community_id])
        end

        render json: @posts.map { |p| post_json(p) }
      end

      # GET /api/v1/posts/:id
      def show
        render json: post_json(@post, detailed: true)
      end

      # POST /api/v1/posts
      def create
        @post = current_api_user.posts.new(post_params)

        if @post.save
          render json: post_json(@post), status: :created
        else
          render json: {
            error: 'Validation failed',
            details: @post.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PUT/PATCH /api/v1/posts/:id
      def update
        if @post.update(post_params)
          render json: post_json(@post)
        else
          render json: {
            error: 'Validation failed',
            details: @post.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/posts/:id
      def destroy
        @post.destroy
        head :no_content
      end

      private

      def set_post
        @post = Post.find(params[:id])
      end

      def authorize_post_owner!
        authorize_owner!(@post)
      end

      def post_params
        params.require(:post).permit(:title, :url, :body, :community_id)
      end

      def post_json(post, detailed: false)
        json = {
          id: post.id,
          title: post.title,
          url: post.url,
          body: post.body,
          created_at: post.created_at,
          updated_at: post.updated_at,
          user: {
            id: post.user.id,
            username: post.user.username,
            display_name: post.user.display_name
          },
          community: {
            id: post.community.id,
            slug: post.community.slug,
            name: post.community.name
          }
        }

        if detailed
          json.merge!(
            comments_count: post.comments.count,
            comments: post.comments.includes(:user).map { |c| comment_json(c) }
          )
        else
          json[:comments_count] = post.comments.count
        end

        json
      end

      def comment_json(comment)
        {
          id: comment.id,
          body: comment.body,
          created_at: comment.created_at,
          user: {
            id: comment.user.id,
            username: comment.user.username
          }
        }
      end
    end
  end
end