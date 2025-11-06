class CommunitiesController < ApplicationController
  before_action :set_community, only: %i[ show edit update destroy ]

  def index
    @communities = Community.order(:slug)
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

  private

  # Buscar por slug (params[:id] contiene el slug gracias a to_param)
  def set_community
    @community = Community.find_by!(slug: params[:id])
  end

  # Permitir imágenes (multipart en el form)
  def community_params
    params.require(:community).permit(:slug, :name, :banner, :avatar)
  end
end