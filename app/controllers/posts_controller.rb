class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :require_login, only: %i[ new create edit update destroy ]

  def index
    @posts = Post.includes(:user, :community).order(created_at: :desc) # más nuevo primero
  end

  def show
  end

  def new
    @post = Post.new
    @communities = Community.order(:slug)  # 🔥 cargar comunidades para el selector
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to posts_path, notice: "Post creado correctamente."
    else
      @communities = Community.order(:slug) # recargar comunidades si hay error
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @communities = Community.order(:slug)
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post actualizado."
    else
      @communities = Community.order(:slug)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_url, notice: "Post eliminado."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :url, :body, :community_id, :image)  # 🔥 ahora community_id
  end
end