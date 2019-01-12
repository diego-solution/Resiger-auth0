# frozen_string_literal: true

# handles authentication using jwt token instead of devise
module TokenAuthentication
  # provides the more graceful `included` method
  extend ActiveSupport::Concern

  # TODO: should be similar to the namespace on the auth0 custom rules
  TOKEN_CUSTOM_DATA_NAMESPACE = "http://token-custom-data.eventfuel.io/"

  protected

  # Validates the token and user and sets the @current_user scope
  def authenticate_request!
    unless JsonWebToken.valid_payload(payload.first)
      logger.debug("###token is not valid")
      return invalid_authentication
    end
    load_current_user!
    #save_last_seen_at

    user_not_exists unless @current_user
  end

  # Returns 401 response. To handle malformed / invalid requests.
  def invalid_authentication
    render_error(RESPONSE_CODE[:unauthorized], "Your session has expired. Please login again.", "")
  end

  # Returns 404 response. To handle not existing user profile in Register.
  def user_not_exists
    render_error(RESPONSE_CODE[:not_found], "We were unable to find your account details, please contact Eventfuel support.", "notFoundUser")
  end

  private

  # Deconstructs the Authorization header and decodes the JWT token.
  def payload
    token = request.headers.fetch("Authorization", "").split(" ").last
    response = JsonWebToken.decode(token)
    response
  end

  # Sets the @current_user with the user_id from payload
  def load_current_user!
    email = parse_user_identify
    @current_user = User.find_by(email: email)
  end

  def parse_user_identify
    # TODO: should use sub because we can have same email in
    #       multiple identity providers.
    #email = payload[0]["sub"].split('|').last
    payload[0][TOKEN_CUSTOM_DATA_NAMESPACE + "email"]
  end

  def parse_app_metadata(payload)
    payload[0][TOKEN_CUSTOM_DATA_NAMESPACE + "app_metadata"]
  end

  def parse_user_metadata(payload)
    payload[0][TOKEN_CUSTOM_DATA_NAMESPACE + "user_metadata"]
  end

  def save_last_seen_at
    @current_user.update_attributes(sign_in_count: @current_user.sign_in_count + 1,
                                    current_sign_in_at: Time.current)
  end
end
