class UsersController < ApplicationController
  skip_before_action :authenticate, only: :create
  before_action :get_user

  def show
    render json: @user
  end

  def create
    decoded_token = FirebaseUtils::Auth.verify_id_token(token)
    @user = User.create!(user_params.merge(firebase_uid: decoded_token['uid']))
    render json: @user
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
