class CommunitiesController < ApplicationController
  before_action :set_community, only: %i[ show edit update destroy ]
  before_action :require_login

  def index
    case params[:filter]
    when "subscribed"
      @communities = current_user.subscribed_communities.order(:slug)
    else # "local"
      @communities = Community.order(:slug)
    end
  end

  def show
  end

  def new
    @community = Community.new
  end

  def edit
  end

  def create
    @community = Community.new(community_params)
    if @community.save
      redirect_to @community, notice: "Community creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @community.update(community_params)
      redirect_to @community, notice: "Community actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @community.destroy
    redirect_to communities_url, notice: "Community eliminada."
  end

  # ----- Suscripciones -----
  def subscribe
    community = Community.find_by!(slug: params[:id])
    current_user.subscriptions.find_or_create_by!(community: community)
    redirect_back fallback_location: community_path(community)
  end

  def unsubscribe
    community = Community.find_by!(slug: params[:id])
    current_user.subscriptions.where(community: community).delete_all
    redirect_back fallback_location: community_path(community)
  end

  private

  def set_community
    @community = Community.find_by!(slug: params[:id])
  end

  def community_params
    params.require(:community).permit(:slug, :name, :banner, :avatar)
  end
end
