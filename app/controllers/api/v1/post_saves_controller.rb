module Api
  module V1
    class PostSavesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_post

      def create
        if @post.saves.exists?(user: current_user)
          respond_to do |format|
            format.json { render json: { error: 'Post already saved' }, status: :conflict }
            # Si ya estaba guardado, volvemos atrás con un aviso
            format.html { redirect_back fallback_location: root_path, alert: 'Este post ya estaba guardado.' }
          end
        else
          @post.saves.create!(user: current_user)
          respond_to do |format|
            format.json { head :created }
            # AQUÍ ESTÁ LA MAGIA: Volvemos atrás con mensaje de éxito
            format.html { redirect_back fallback_location: root_path, notice: 'Post guardado correctamente.' }
          end
        end
      end

      def destroy
        save = @post.saves.find_by(user: current_user)
        if save
          save.destroy
          respond_to do |format|
            format.json { head :no_content }
            format.html { redirect_back fallback_location: root_path, notice: 'Post eliminado de guardados.' }
          end
        else
          respond_to do |format|
            format.json { render json: { error: 'Post not in saved list' }, status: :not_found }
            format.html { redirect_back fallback_location: root_path, alert: 'No tenías este post guardado.' }
          end
        end
      end

      private
      def set_post
        @post = Post.find(params[:post_id])
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.json { render json: { error: 'Post not found' }, status: :not_found }
          format.html { redirect_back fallback_location: root_path, alert: 'El post no existe.' }
        end
      end
    end
  end
end