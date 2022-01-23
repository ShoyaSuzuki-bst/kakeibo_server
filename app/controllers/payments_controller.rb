# frozen_string_literal: true

# test
class PaymentsController < ApplicationController
  before_action :get_payment, except: [:index, :create]
  def index
    @payments = Payment.where(user_id: @current_user.id).order(created_at: 'DESC')
    render json: @payments, each_serializer: PaymentSerializer
  end

  def show
    render json: @payment, serializer: PaymentSerializer
  end

  def create
    begin
      @payment = Payment.create!(payment_params.merge(user_id: @current_user.id))
    rescue StandardError => e
      return render json: {'message': e.message}, status: 500
    end
    render json: @payment, serializer: PaymentSerializer
  end

  def update
    @payment.update!(payment_params)
    render json: @payment, serializer: PaymentSerializer
  end

  def destroy
    @payment.destroy!
    render json: {
      status: 'deleted successfully'
    }
  end

  private

  def get_payment
    @payment = Payment.find(params[:id])
  end

  def payment_params
    params.require(:payment).permit(:price, :is_income)
  end
end
