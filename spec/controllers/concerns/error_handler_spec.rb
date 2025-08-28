require 'rails_helper'

RSpec.describe ErrorHandler, type: :controller do
  controller(Api::V1::BaseController) do
    include ErrorHandler

    def index
      case params[:error_type]
      when 'not_found'
        raise ActiveRecord::RecordNotFound, 'Product not found'
      when 'invalid'
        product = Product.new
        product.valid?
        raise ActiveRecord::RecordInvalid, product
      when 'argument'
        raise ArgumentError, 'Invalid argument provided'
      else
        render json: { message: 'success' }
      end
    end
  end

  describe 'error handling' do
    context 'ActiveRecord::RecordNotFound' do
      it 'rescues and returns not found error' do
        get :index, params: { error_type: 'not_found' }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Product not found')
      end
    end

    context 'ActiveRecord::RecordInvalid' do
      it 'rescues and returns validation error' do
        get :index, params: { error_type: 'invalid' }
        expect(response).to have_http_status(:unprocessable_entity)
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Validation failed')
        expect(json_response['details']).to be_an(Array)
      end
    end

    context 'ArgumentError' do
      it 'rescues and returns bad request error' do
        get :index, params: { error_type: 'argument' }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Invalid argument provided')
      end
    end
  end


end