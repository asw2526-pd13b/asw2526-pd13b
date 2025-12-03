class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_user!, only: [:edit, :update]

  def index
    @users = User.order(created_at: :desc)
  end

  def show
    @posts = @user.posts.order(created_at: :desc).limit(20)
    @comments = @user.comments.includes(:post).order(created_at: :desc).limit(20)

    # Tab actiu (per defecte: posts)
    @active_tab = params[:tab] || 'posts'
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "Perfil actualitzat correctament."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def regenerate_api_key
    @user = User.find(params[:id])
    authorize_user!

    @user.regenerate_api_key!
    redirect_to @user, notice: "API Key regenerada correctament."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user!
    unless @user == current_user
      redirect_to root_path, alert: "No tens permís per editar aquest perfil."
    end
  end

  def user_params
    params.require(:user).permit(:display_name, :bio, :banner_url)
  end
end