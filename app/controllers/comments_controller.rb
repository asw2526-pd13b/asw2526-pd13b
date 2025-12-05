class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_post, only: :create
  before_action :authorize_comment_owner, only: [:destroy]

  def index
    @comments = Comment.includes(:user, :post).order(created_at: :desc).limit(50)
  end

  def create
    @comment = current_user.comments.build(comment_params.merge(post: @post))

    if @comment.save
      redirect_to post_path(@post, sort: params[:sort]), notice: "Comentario creado."
    else
      # Volvemos al show del post mostrando los errores
      @comments = load_sorted_comments(@post, params[:sort])
      flash.now[:alert] = "No se pudo crear el comentario."
      render "posts/show", status: :unprocessable_entity
    end
  end

  def destroy
    comment = Comment.find(params[:id])
    post = comment.post

    if current_user == comment.user
      comment.destroy
      redirect_back fallback_location: post_path(post), notice: "Comentari esborrat."
    else
      redirect_back fallback_location: post_path(post), alert: "No tienes permiso para borrar esto."
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  # Para reusar el orden al re-renderizar el show
  def load_sorted_comments(post, sort_param)
    case sort_param
    when "old" then post.comments.includes(:user).oldest_first
    # "popular" lo implementaremos más adelante con votos
    else            post.comments.includes(:user).newest_first
    end
  end

  def authorize_comment_owner
    comment = Comment.find(params[:id])
    unless comment.user_id == current_user.id
    redirect_back fallback_location: posts_path, alert: "No tens permís per fer això."
  end
end

end
