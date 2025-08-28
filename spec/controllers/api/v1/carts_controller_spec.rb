require 'rails_helper'

RSpec.describe Api::V1::CartsController, type: :controller do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, stock_quantity: 10) }

  describe 'GET #show' do
    context 'when cart_id exists in session' do
      before { session[:cart_id] = cart.id }

      it 'returns http success' do
        get :show
        expect(response).to have_http_status(:success)
      end

      it 'calls Carts::FindOrCreate service' do
        expect(Carts::FindOrCreate).to receive(:call).with(cart.id).and_return(cart)
        get :show
      end

      it 'calls CartSerializer.serialize' do
        expect(CartSerializer).to receive(:serialize).with(cart).and_call_original
        get :show
      end

      it 'maintains cart_id in session' do
        get :show
        expect(session[:cart_id]).to eq(cart.id)
      end
    end

    context 'when cart_id does not exist in session' do
      let(:new_cart) { create(:cart) }

      before do
        allow(Carts::FindOrCreate).to receive(:call).with(nil).and_return(new_cart)
      end

      it 'creates a new cart' do
        expect(Carts::FindOrCreate).to receive(:call).with(nil).and_return(new_cart)
        get :show
      end

      it 'sets cart_id in session' do
        get :show
        expect(session[:cart_id]).to eq(new_cart.id)
      end
    end
  end

  describe 'POST #create' do
    let(:new_cart) { create(:cart) }

    before do
      allow(Carts::FindOrCreate).to receive(:call).with(no_args).and_return(new_cart)
    end

    it 'returns created status' do
      post :create
      expect(response).to have_http_status(:created)
    end

    it 'calls Carts::FindOrCreate service' do
      expect(Carts::FindOrCreate).to receive(:call).with(no_args).and_return(new_cart)
      post :create
    end

    it 'calls CartSerializer.serialize' do
      expect(CartSerializer).to receive(:serialize).with(new_cart).and_call_original
      post :create
    end

    it 'sets cart_id in session' do
      post :create
      expect(session[:cart_id]).to eq(new_cart.id)
    end
  end

  describe 'POST #add_item' do
    before { session[:cart_id] = cart.id }

    context 'with valid parameters' do
      let(:success_result) { { success: true, cart: cart } }

      before do
        allow(Carts::AddItem).to receive(:call).and_return(success_result)
      end

      it 'returns http success' do
        post :add_item, params: { product_id: product.id, quantity: 2 }
        expect(response).to have_http_status(:success)
      end

      it 'calls Carts::AddItem service with correct parameters' do
        expect(Carts::AddItem).to receive(:call).with(cart, product, 2)
        post :add_item, params: { product_id: product.id, quantity: 2 }
      end

      it 'defaults quantity to 1 when not provided' do
        expect(Carts::AddItem).to receive(:call).with(cart, product, 1)
        post :add_item, params: { product_id: product.id }
      end

      it 'calls CartSerializer.serialize' do
        expect(CartSerializer).to receive(:serialize).with(cart).and_call_original
        post :add_item, params: { product_id: product.id, quantity: 2 }
      end
    end

    context 'when service returns error' do
      let(:error_result) { { success: false, error: 'Product out of stock' } }

      before do
        allow(Carts::AddItem).to receive(:call).and_return(error_result)
      end

      it 'returns unprocessable_entity status' do
        post :add_item, params: { product_id: product.id, quantity: 2 }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid product_id' do
      it 'returns not_found status' do
        post :add_item, params: { product_id: 999, quantity: 2 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE #remove_item' do
    before { session[:cart_id] = cart.id }

    context 'when item exists in cart' do
      let(:success_result) { { success: true, cart: cart } }

      before do
        allow(Carts::RemoveItem).to receive(:call).and_return(success_result)
      end

      it 'returns http success' do
        delete :remove_item, params: { product_id: product.id }
        expect(response).to have_http_status(:success)
      end

      it 'calls Carts::RemoveItem service' do
        expect(Carts::RemoveItem).to receive(:call).with(cart, product)
        delete :remove_item, params: { product_id: product.id }
      end

      it 'calls CartSerializer.serialize' do
        expect(CartSerializer).to receive(:serialize).with(cart).and_call_original
        delete :remove_item, params: { product_id: product.id }
      end
    end

    context 'when item does not exist in cart' do
      let(:error_result) { { success: false, error: 'Product not found in cart' } }

      before do
        allow(Carts::RemoveItem).to receive(:call).and_return(error_result)
      end

      it 'returns not_found status' do
        delete :remove_item, params: { product_id: product.id }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid product_id' do
      it 'returns not_found status' do
        delete :remove_item, params: { product_id: 999 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT #update_item' do
    before { session[:cart_id] = cart.id }

    context 'with valid parameters' do
      let(:success_result) { { success: true, cart: cart } }

      before do
        allow(Carts::UpdateQuantity).to receive(:call).and_return(success_result)
      end

      it 'returns http success' do
        put :update_item, params: { product_id: product.id, quantity: 3 }
        expect(response).to have_http_status(:success)
      end

      it 'calls Carts::UpdateQuantity service' do
        expect(Carts::UpdateQuantity).to receive(:call).with(cart, product, 3)
        put :update_item, params: { product_id: product.id, quantity: 3 }
      end

      it 'calls CartSerializer.serialize' do
        expect(CartSerializer).to receive(:serialize).with(cart).and_call_original
        put :update_item, params: { product_id: product.id, quantity: 3 }
      end
    end

    context 'when quantity is not provided' do
      it 'returns bad_request status' do
        put :update_item, params: { product_id: product.id }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when service returns error' do
      let(:error_result) { { success: false, error: 'Insufficient stock' } }

      before do
        allow(Carts::UpdateQuantity).to receive(:call).and_return(error_result)
      end

      it 'returns not_found status' do
        put :update_item, params: { product_id: product.id, quantity: 3 }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid product_id' do
      it 'returns not_found status' do
        put :update_item, params: { product_id: 999, quantity: 3 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE #clear' do
    before { session[:cart_id] = cart.id }

    it 'returns http success' do
      delete :clear
      expect(response).to have_http_status(:success)
    end

    it 'calls Carts::Clear service' do
      expect(Carts::Clear).to receive(:call).with(cart).and_return(cart)
      delete :clear
    end

    it 'calls CartSerializer.serialize' do
      expect(CartSerializer).to receive(:serialize).with(cart).and_call_original
      delete :clear
    end
  end
end