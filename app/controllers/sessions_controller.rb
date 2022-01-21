class SessionsController < ApplicationController
  def test
    render json: {
      status: 'success',
      user: @current_user
    }
  end
end
