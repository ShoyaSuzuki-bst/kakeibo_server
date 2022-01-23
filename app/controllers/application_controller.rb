class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :authenticate

  protected
  def authenticate
    sleep(3) if Rails.env.development?
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_or_request_with_http_token do |token, _|
      decoded_token = FirebaseUtils::Auth.verify_id_token(token)
      firebase_id = decoded_token['uid']
      @current_user = User.find_by!(firebase_uid: firebase_id)
    end
  end

  def render_unauthorized
    obj = { message: '認証に失敗しました。初めての場合は新規登録をお願いします。' }
    render json: obj, status: :unauthorized
  end
end
