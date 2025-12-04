class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]
  before_action :require_login, only: %i[new create edit update destroy]
  before_action :authorize_post_owner, only: %i[edit update destroy]

  def index
    @posts = Post.includes(:user, :community)

    if params[:q].present?
      q = "%#{params[:q]}%"
      @posts = @posts.where("title LIKE :q OR body LIKE :q", q: q)
    end

    case params[:filter]
    when "subscribed"
      if current_user.respond_to?(:subscribed_communities)
        ids = current_user.subscribed_communities.pluck(:id)
        @posts = @posts.where(community_id: ids)
      end
    when "local"
    end

    case params[:sort]
    when "old"
      @posts = @posts.order(created_at: :asc)
    when "comments"
      @posts = @posts.left_joins(:comments).group(:id).order("COUNT(comments.id) DESC")
    when "top", "popular"
      score_sql = "CASE WHEN COALESCE(SUM(votes.value), 0) < 0 THEN 0 ELSE COALESCE(SUM(votes.value), 0) END"
      @posts = @posts.left_joins(:votes).group("posts.id").order(Arel.sql("#{score_sql} DESC, posts.created_at DESC"))
    else
      @posts = @posts.order(created_at: :desc)
    end
  end

  def show
  end

  def new
    @post = Post.new
    @communities = Community.order(:slug)
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to posts_path, notice: "Post creado correctamente."
    else
      @communities = Community.order(:slug)
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
    params.require(:post).permit(:title, :url, :body, :community_id, :image)
  end

  def authorize_post_owner
    return if @post.user_id == current_user.id
    redirect_to posts_path, alert: "No tens permís per fer això."
  end
end
