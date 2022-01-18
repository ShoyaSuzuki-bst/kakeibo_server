class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :authenticate

  protected
  def authenticate
    authenticate_or_request_with_http_token do |token, _|
      # @firebase_id = FirebaseUtils::Auth.verify_id_token(token)
      decoded_token = FirebaseUtils::Auth.verify_id_token(token)
      @firebase_id = decoded_token['uid']
      @current_user = User.find_by!(firebase_uid: @firebase_id)
    end
  end
end
