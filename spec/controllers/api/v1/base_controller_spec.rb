require 'rails_helper'

RSpec.describe Api::V1::BaseController, type: :controller do
  controller do
    def index
      render_success({ message: 'test' })
    end

    def create
      render_error('Test error', :bad_request)
    end

    def show
      render json: { test: true }
    end
  end

  describe 'default response format' do
    it 'sets request format to JSON' do
      get :index
      expect(request.format.symbol).to eq(:json)
    end
  end

  describe '#render_success' do
    it 'renders JSON with success status' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')
      expect(JSON.parse(response.body)).to eq({ 'message' => 'test' })
    end
  end

  describe '#render_error' do
    it 'renders JSON error with specified status' do
      post :create
      expect(response).to have_http_status(:bad_request)
      expect(response.content_type).to include('application/json')
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Test error' })
    end
  end

  describe 'JSON response' do
    it 'returns JSON content type by default' do
      get :index
      expect(response.content_type).to include('application/json')
    end
  end
end