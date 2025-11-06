class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :require_login, only: %i[ new create edit update destroy ]

  def index
    @posts = Post.includes(:user).order(created_at: :desc) # más nuevo primero
  end

  def show; end

  def new
    @post = Post.new(community: "programming") # comunidad hardcoded de momento
  end

  def create
    @post = current_user.posts.build(post_params)
    @post.community ||= "programming"

    if @post.save
      redirect_to posts_path, notice: "Post creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post actualizado."
    else
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
    params.require(:post).permit(:title, :url, :body, :community)
  end
end