module AuthHelper
  def http_login(company = nil)
    user = company.subdomain
    password = company.api_token
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,password)
  end

  def http_login2(user = nil,password = nil)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,password)
  end
end
