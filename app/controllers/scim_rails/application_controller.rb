module ScimRails
  class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Basic::ControllerMethods
    include ExceptionHandler
    include Response

    before_action :authorize_request

    private

    def authorize_request
      authorization = nil
      # I want to only use the basic auth and eliminate the oauth strategy. Less tests to maintain.....
      # byebug
      send(authentication_strategy) do |searchable_attribute, authentication_attribute|
        # byebug
        authorization = AuthorizeApiRequest.new(
          searchable_attribute: searchable_attribute,
          authentication_attribute: authentication_attribute
        )
        # byebug
      end
      raise ScimRails::ExceptionHandler::InvalidCredentials unless authorization&.authenticated2?
    end

    def authentication_strategy
      byebug
      if request.headers["Authorization"]&.include?("Bearer")
        :authenticate_with_oauth_bearer
      else
        :authenticate_with_http_basic
      end
    end

    def authenticate_with_oauth_bearer
      authentication_attribute = request.headers["Authorization"].split(" ").last
      payload = ScimRails::Encoder.decode(authentication_attribute).with_indifferent_access
      searchable_attribute = payload[ScimRails.config.basic_auth_model_searchable_attribute]

      yield searchable_attribute, authentication_attribute
    end
  end
end
