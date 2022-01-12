class SessionsController < ApplicationController
  skip_before_action :login_required, only: [:show, :create]

  def show
    if session[:firebase_uid]
      render json: { logged_in: true }
    else
      render json: { logged_in: false }
    end
  end

  def create
    request_params = SessionsRequestParams.new(params)
    request_params.validate!

    begin
      decoded_token = FirebaseUtils::Auth.verify_id_token(request_params.id_token)
    rescue StandardError => e
      Rails.logger.error('====================')
      Rails.logger.error(e.message)
      Rails.logger.error('====================')

      errors = {
        title: 'ログインエラー',
        messages: [e.message]
      }
      render json: errors, status: :unauthorized
    else
      user = User.find_by(email: decoded_token['decoded_token'][:payload]['email'])
      if user.present?
        user.update!(firebase_uid: decoded_token['decoded_token'][:payload]['user_id'])
        session[:firebase_uid] = user.firebase_uid

        render json: { status: 'Successfully logged in.' }
      else
        errors = {
          title: 'ログインエラー',
          messages: ['新しいユーザーでログインするためには事前のユーザー追加申請が必要です。システム管理者に連絡してください。']
        }
        render json: errors, status: :unauthorized
      end
    end
  end

  def destroy
    current_user.update!(firebase_uid: nil)
    reset_session
    render json: { status: 'Successfully logged out.' }
  end
end
