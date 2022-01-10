# frozen_string_literal: true

# test
class PaymentsController < ApplicationController
  before_action :get_payment, except: [:index, :create]
  def index
    @payments = Payment.all
    render json: @payments, each_serializer: PaymentSerializer
  end

  def show
    render json: @payment, serializer: PaymentSerializer
  end

  def create
    @payment = Payment.create!(payment_params)
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
    params.permit(:is_income, :price)
  end
end
