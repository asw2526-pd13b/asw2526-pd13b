module Api
  module V1
    class CommunitiesController < BaseController
      def index
        communities =
          case params[:filter]
          when "subscribed"
            current_user.subscribed_communities.order(:slug)
          else
            Community.order(:slug)
          end

        render json: communities.map { |c| serialize_community(c) }
      end

      def show
        community = Community.find_by!(slug: params[:id])
        posts = community.posts.includes(:user).order(created_at: :desc).limit(20)
        render json: { community: serialize_community(community), posts: posts.map { |p| serialize_post_summary(p) } }
      end

      def create
        community = Community.new(community_params)
        if community.save
          render json: { community: serialize_community(community) }, status: :created
        else
          render_unprocessable(community)
        end
      end

      def update
        community = Community.find_by!(slug: params[:id])
        if community.update(community_params)
          render json: { community: serialize_community(community) }
        else
          render_unprocessable(community)
        end
      end

      def destroy
        community = Community.find_by!(slug: params[:id])
        community.destroy
        head :no_content
      end

      def subscribe
        community = Community.find_by!(slug: params[:id])
        current_user.subscriptions.find_or_create_by!(community: community)
        render json: { subscribed: true, community: serialize_community(community) }
      end

      def unsubscribe
        community = Community.find_by!(slug: params[:id])
        current_user.subscriptions.where(community: community).delete_all
        render json: { subscribed: false, community: serialize_community(community) }
      end

      private

      def community_params
        params.permit(:slug, :name, :banner, :avatar)
      end

      def serialize_community(community)
        {
          id: community.id,
          slug: community.slug,
          name: community.name,
          avatar_url: attachment_url(community.avatar),
          banner_url: attachment_url(community.banner),
          subscribers_count: community.subscribers.count,
          created_at: community.created_at,
          updated_at: community.updated_at
        }
      end

      def serialize_post_summary(post)
        {
          id: post.id,
          title: post.title,
          url: post.url,
          body: post.body,
          user: { id: post.user.id, username: post.user.username, name: post.user.name, avatar_url: post.user.avatar_url },
          score: post.score,
          created_at: post.created_at
        }
      end
    end
  end
end
