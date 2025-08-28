require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  describe 'GET #index' do
    before do
      Product.destroy_all
      create_list(:product, 3)
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'calls ProductSerializer.serialize_collection' do
      Product.destroy_all
      create_list(:product, 3)
      expect(ProductSerializer).to receive(:serialize_collection).with(Product.all).and_call_original
      get :index
    end

    it 'returns all products in response' do
      expect(JSON.parse(response.body)).to be_an(Array)
      expect(JSON.parse(response.body).length).to eq(3)
    end
  end

  describe 'GET #show' do
    let(:product) { create(:product) }

    context 'with valid id' do
      before { get :show, params: { id: product.id } }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'calls ProductSerializer.serialize' do
        expect(ProductSerializer).to receive(:serialize).with(product).and_call_original
        get :show, params: { id: product.id }
      end
    end

    context 'with invalid id' do
      it 'returns not_found status' do
        get :show, params: { id: 999 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_attributes) { { name: 'Test Product', price: 19.99, category: 'electronics', stock_quantity: 10 } }

      it 'creates a new Product' do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
      end

      it 'returns created status' do
        post :create, params: { product: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it 'calls ProductSerializer.serialize' do
        expect(ProductSerializer).to receive(:serialize).and_call_original
        post :create, params: { product: valid_attributes }
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: '', price: -1 } }

      it 'does not create a new Product' do
        expect {
          post :create, params: { product: invalid_attributes }
        }.not_to change(Product, :count)
      end

      it 'returns unprocessable_entity status' do
        post :create, params: { product: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    let(:product) { create(:product) }

    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Product', price: 29.99 } }

      before { put :update, params: { id: product.id, product: new_attributes } }

      it 'updates the requested product' do
        product.reload
        expect(product.name).to eq('Updated Product')
        expect(product.price).to eq(29.99)
      end

      it 'returns ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'calls ProductSerializer.serialize' do
        expect(ProductSerializer).to receive(:serialize).with(product).and_call_original
        put :update, params: { id: product.id, product: new_attributes }
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: '', price: -1 } }

      it 'returns unprocessable_entity status' do
        put :update, params: { id: product.id, product: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid product id' do
      it 'returns not_found status' do
        put :update, params: { id: 999, product: { name: 'Test' } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:product) { create(:product) }

    it 'destroys the requested product' do
      expect {
        delete :destroy, params: { id: product.id }
      }.to change(Product, :count).by(-1)
    end

    it 'returns no_content status' do
      delete :destroy, params: { id: product.id }
      expect(response).to have_http_status(:no_content)
    end

    context 'with invalid product id' do
      it 'returns not_found status' do
        delete :destroy, params: { id: 999 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'private methods' do
    describe '#product_params' do
      let(:params) { ActionController::Parameters.new(product: { name: 'Test', price: 10.0, category: 'electronics', stock_quantity: 5, unauthorized_param: 'hack' }) }

      it 'permits only allowed parameters' do
        controller.params = params
        permitted_params = controller.send(:product_params)
        expect(permitted_params.keys).to match_array(['name', 'price', 'category', 'stock_quantity'])
      end
    end
  end
end