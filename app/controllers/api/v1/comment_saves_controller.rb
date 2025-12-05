module Api
  module V1
    class CommentSavesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_comment

      def create
        if @comment.saves.exists?(user: current_user)
          respond_to do |format|
            format.json { render json: { error: 'Comment already saved' }, status: :conflict }
            format.html { redirect_back fallback_location: root_path, alert: 'Este comentario ya estaba guardado.' }
          end
        else
          @comment.saves.create!(user: current_user)
          respond_to do |format|
            format.json { head :created }
            format.html { redirect_back fallback_location: root_path, notice: 'Comentario guardado correctamente.' }
          end
        end
      end

      def destroy
        save = @comment.saves.find_by(user: current_user)
        if save
          save.destroy
          respond_to do |format|
            format.json { head :no_content }
            format.html { redirect_back fallback_location: root_path, notice: 'Comentario eliminado de guardados.' }
          end
        else
          respond_to do |format|
            format.json { render json: { error: 'Comment not in saved list' }, status: :not_found }
            format.html { redirect_back fallback_location: root_path, alert: 'No tenías este comentario guardado.' }
          end
        end
      end

      private
      def set_comment
        @comment = Comment.find(params[:comment_id])
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.json { render json: { error: 'Comment not found' }, status: :not_found }
          format.html { redirect_back fallback_location: root_path, alert: 'El comentario no existe.' }
        end
      end
    end
  end
end