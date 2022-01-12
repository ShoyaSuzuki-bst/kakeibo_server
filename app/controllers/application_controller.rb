class ApplicationController < ActionController::API
  before_action :login_required

  def current_user
    @current_user ||= User.find_by!(firebase_uid: session[:firebase_uid]) if session[:firebase_uid]
  end

  def login_required
    # Lambda承認が成功すればログイン判定は不要
    return if authorize_lambda_access

    errors = {
      title: '認証エラー',
      messages: ['この操作を行うためには先にログインが必要です。']
    }
    render json: errors, status: :unauthorized unless current_user
  end
end
