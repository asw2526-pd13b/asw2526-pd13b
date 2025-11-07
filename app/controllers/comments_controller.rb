class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_post, only: :create

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
    @comment = current_user.comments.find(params[:id])
    post = @comment.post
    @comment.destroy
    redirect_to post_path(post, sort: params[:sort]), notice: "Comentario eliminado."
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
end
