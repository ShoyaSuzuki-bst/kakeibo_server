class UsersController < ApplicationController
  skip_before_action :authenticate, only: :create

  def show; end

  def create; end

  def update; end

  def destroy; end
end
