class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :require_login, only: %i[ new create edit update destroy ]

def index
  # --- 🔹 Punt de partida: carregar posts amb usuari i comunitat
  @posts = Post.includes(:user, :community)

  # ---  Cercador
  if params[:q].present?
    query = "%#{params[:q]}%"
    @posts = @posts.where("title ILIKE ? OR body ILIKE ?", query, query)
  end

  # --- ⚙ Filtres
  case params[:filter]
  when "subscribed"
    if current_user.respond_to?(:subscribed_communities)
      ids = current_user.subscribed_communities.pluck(:id)
      @posts = @posts.where(community_id: ids)
    end
  when "local"
    # No fem res especial, simplement mostrem tots els posts locals
  end

    # ---  Ordenació addicional
  case params[:sort]
  when "old"
    @posts = @posts.order(created_at: :asc)
  when "popular"
    # En aquest lliurament encara no tenim vots, així que ordenem per nombre de comentaris
    @posts = @posts.left_joins(:comments)
                   .group("posts.id")
                   .order("COUNT(comments.id) DESC")
  else
    @posts = @posts.order(created_at: :desc)
  end

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