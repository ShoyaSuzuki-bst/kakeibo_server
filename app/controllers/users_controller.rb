class UsersController < ApplicationController
  skip_before_action :authenticate, only: :create
  before_action :get_user, except: [:show, :create]

  def show
    render json: @current_user
  end

  def create
    authenticate_or_request_with_http_token do |token, _|
      decoded_token = FirebaseUtils::Auth.verify_id_token(token)
      @user = User.create!(user_params.merge(firebase_uid: decoded_token['uid']))
      return render json: @user
    end
  end

  def update
    @user.update!(user_params)
    render json: @user
  end

  def destroy
    @user.destroy!
    render json: {status: 'ok'}
  end

  private

  def user_params
    params.permit(:name, :email)
  end

  def get_user
    @user = User.find(params[:id])
  end
end
