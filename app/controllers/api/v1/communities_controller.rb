module Api
  module V1
    class CommunitiesController < BaseController
      before_action :authenticate_api_key!, except: [:index, :show]
      before_action :set_community, only: [:show, :update, :destroy, :subscribe, :unsubscribe]

      # GET /api/v1/communities
      def index
        @communities = Community.all
        render json: @communities.map { |c| community_json(c) }
      end

      # GET /api/v1/communities/:id
      def show
        render json: community_json(@community, detailed: true)
      end

      # POST /api/v1/communities
      def create
        @community = Community.new(community_params)

        if @community.save
          render json: community_json(@community), status: :created
        else
          render json: {
            error: 'Validation failed',
            details: @community.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PUT/PATCH /api/v1/communities/:id
      def update
        if @community.update(community_params)
          render json: community_json(@community)
        else
          render json: {
            error: 'Validation failed',
            details: @community.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/communities/:id
      def destroy
        @community.destroy
        head :no_content
      end

      # POST /api/v1/communities/:id/subscribe
      def subscribe
        subscription = current_api_user.subscriptions.find_or_create_by(community: @community)

        if subscription.persisted?
          render json: { message: 'Subscribed successfully' }, status: :ok
        else
          render json: { error: 'Could not subscribe' }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/communities/:id/unsubscribe
      def unsubscribe
        subscription = current_api_user.subscriptions.find_by(community: @community)

        if subscription&.destroy
          render json: { message: 'Unsubscribed successfully' }, status: :ok
        else
          render json: { error: 'Not subscribed' }, status: :not_found
        end
      end

      private

      def set_community
        @community = Community.find(params[:id])
      end

      def community_params
        params.require(:community).permit(:slug, :name)
      end

      def community_json(community, detailed: false)
        json = {
          id: community.id,
          slug: community.slug,
          name: community.name,
          created_at: community.created_at,
          updated_at: community.updated_at
        }

        if detailed
          json.merge!(
            posts_count: community.posts.count,
            subscribers_count: community.subscriptions.count
          )
        end

        json
      end
    end
  end
end