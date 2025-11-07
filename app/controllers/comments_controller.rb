class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_post
  before_action :set_comment, only: :destroy
  before_action :authorize_owner!, only: :destroy

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))
    if @comment.save
      redirect_to post_path(@post, anchor: "comment-#{@comment.id}"), notice: "Comentario publicado."
    else
      # Volvemos al show con errores, recargando todo server-side (sin JS)
      @order = permitted_order(params[:order])
      @reply_to = params[:comment][:parent_id].presence && @post.comments.find_by(id: params[:comment][:parent_id])
      @comments = load_comments(@order)
      flash.now[:alert] = "El comentario no puede estar vacío."
      render "posts/show", status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    redirect_to post_path(@post), notice: "Comentario eliminado."
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def authorize_owner!
    head :forbidden unless @comment.user_id == current_user.id
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  # Helpers para ordenar comentarios
  def permitted_order(order)
    %w[new old popular].include?(order) ? order : "new"
  end

  def load_comments(order)
    scope = @post.comments.includes(:user, :children)
    case order
    when "old"     then scope.order(created_at: :asc)
    when "popular" then scope.order(created_at: :desc) # TODO: sustituir por score cuando haya votos
    else                scope.order(created_at: :desc) # "new"
    end
  end
end