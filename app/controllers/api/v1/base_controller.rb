module Api
  module V1
    class BaseController < ApplicationController
      # Desactivar CSRF per l'API (usarem API keys)
      skip_before_action :verify_authenticity_token

      # Resposta JSON per defecte
      respond_to :json

      # Gestió d'errors
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

      private

      # Autenticació amb API Key
      def authenticate_api_key!
        unless current_api_user
          render json: { error: 'API Key missing or invalid' }, status: :unauthorized
        end
      end

      # Current user per l'API
      def current_api_user
        @current_user
      end

      # Gestió d'errors 404
      def not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end

      # Gestió d'errors de validació
      def unprocessable_entity(exception)
        render json: {
          error: 'Validation failed',
          details: exception.record.errors.full_messages
        }, status: :unprocessable_entity
      end

      # Verificar que l'usuari sigui el propietari del recurs
      def authorize_owner!(resource)
        unless resource.user_id == current_api_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden
          return false
        end
        true
      end

      # Obtenir current_api_user sense requerir autenticació
      def current_api_user
        return @current_user if defined?(@current_user)

        api_key = request.headers['X-API-Key']
        @current_user = User.find_by(api_key: api_key) if api_key.present?
      end
    end
  end
end