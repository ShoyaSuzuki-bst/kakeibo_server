class SessionsController < ApplicationController
  skip_before_action :authenticate, only: [:show, :create]

  def show
    if session[:firebase_uid]
      render json: { logged_in: true }
    else
      render json: { logged_in: false }
    end
  end

  def create
    begin
      decoded_token = FirebaseUtils::Auth.verify_id_token(session_params[:id_token])
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
      user = User.find_or_create_by(email: decoded_token['decoded_token'][:payload]['email'])
      user.update!(firebase_uid: decoded_token['decoded_token'][:payload]['user_id'])
      render json: user
    end
  end

  def destroy
    @current_user.update!(firebase_uid: nil)
    @current_user = nil
    render json: { status: 'Successfully logged out.' }
  end

  private

  def session_params
    params.permit(:email, :id_token)
  end
end
