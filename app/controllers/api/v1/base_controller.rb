module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_with_api_key!

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "not_found" }, status: :not_found
      end

      rescue_from ActionController::ParameterMissing do |e|
        render json: { error: "bad_request", message: e.message }, status: :bad_request
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        render json: { error: "unprocessable_entity", details: e.record.errors.to_hash(true) }, status: :unprocessable_entity
      end

      private

      attr_reader :current_user

      def authenticate_with_api_key!
        key = request.headers["X-API-Key"].presence || request.headers["X-Api-Key"].presence || params[:api_key].presence
        user = key && User.find_by(api_key: key)
        if user.nil?
          render json: { error: "unauthorized" }, status: :unauthorized
        else
          @current_user = user
        end
      end

      def attachment_url(att)
        return nil unless att&.attached?
        Rails.application.routes.url_helpers.rails_blob_url(att, host: request.base_url)
      end

      def render_unprocessable(record)
        render json: { error: "unprocessable_entity", details: record.errors.to_hash(true) }, status: :unprocessable_entity
      end

      def render_forbidden
        render json: { error: "forbidden" }, status: :forbidden
      end
    end
  end
end
