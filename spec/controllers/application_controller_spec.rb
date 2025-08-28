require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render json: { message: 'test' }
    end
  end

  describe 'basic functionality' do
    it 'responds successfully' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'returns JSON response' do
      get :index
      expect(response.content_type).to include('application/json')
    end
  end
end