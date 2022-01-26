class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :authenticate

  protected
  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_or_request_with_http_token do |token, _|
      decoded_token = FirebaseUtils::Auth.verify_id_token(token)
      @current_user = find_or_create_user(decoded_token)
    end
  end

  def find_or_create_user(decoded_token)
    user = User.find_by(firebase_uid: decoded_token['uid'])
    if user.present?
      return user
    else
      return User.create!(
        name: decoded_token['decoded_token'][:payload]['name'],
        email: decoded_token['decoded_token'][:payload]['email'],
        firebase_uid: decoded_token['uid']
      )
    end
  end

  def render_unauthorized
    obj = { message: '認証に失敗しました。初めての場合は新規登録をお願いします。' }
    render json: obj, status: :unauthorized
  end
end
