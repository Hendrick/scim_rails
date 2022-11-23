module ScimRails
  class AuthorizeApiRequest
    def initialize(searchable_attribute:, authentication_attribute:)
      @searchable_attribute = searchable_attribute
      @authentication_attribute = authentication_attribute

      raise ScimRails::ExceptionHandler::InvalidCredentials if searchable_attribute.blank? || authentication_attribute.blank?

      @search_parameter = {ScimRails.config.basic_auth_model_searchable_attribute => @searchable_attribute}
    end

    def authenticated2?
      if ENV["SCIM_USERNAME"].present? && ENV["SCIM_PASSWORD"].present?
        authorize_basic_auth
      else
        company = find_company
        authorize(company)
        company
      end
    end

    private

    attr_reader :authentication_attribute
    attr_reader :search_parameter
    attr_reader :searchable_attribute

    # company being referenced need to be refactored
    def find_company
      @company ||= ScimRails.config.basic_auth_model.find_by!(search_parameter)
    rescue ActiveRecord::RecordNotFound
      raise ScimRails::ExceptionHandler::InvalidCredentials
    end

    def authorize_basic_auth
      username_authenticated = @searchable_attribute == ENV["SCIM_USERNAME"]
      password_authenticated = @authentication_attribute == ENV["SCIM_PASSWORD"]
      username_authenticated && password_authenticated
    end

    # company being referenced need to be refactored
    def authorize(authentication_model)
      authorized = ActiveSupport::SecurityUtils.secure_compare(
        authentication_model.public_send(ScimRails.config.basic_auth_model_authenticatable_attribute),
        authentication_attribute
      )
      raise ScimRails::ExceptionHandler::InvalidCredentials unless authorized
    end
  end
end
