require 'rails_helper'

RSpec.describe CartSession, type: :controller do
  controller(Api::V1::BaseController) do
    include CartSession

    def index
      render json: { cart_id: current_cart.id }
    end


  end

  let!(:cart) { create(:cart) }
  let!(:product) { create(:product) }

  describe '#current_cart' do
    context 'when cart_id exists in session' do
      before { session[:cart_id] = cart.id }

      it 'returns the existing cart' do
        expect(Carts::FindOrCreate).to receive(:call).with(cart.id).and_return(cart)
        get :index
        expect(JSON.parse(response.body)['cart_id']).to eq(cart.id)
      end

      it 'memoizes the cart' do
        allow(Carts::FindOrCreate).to receive(:call).and_return(cart)
        controller.send(:current_cart)
        controller.send(:current_cart)
        expect(Carts::FindOrCreate).to have_received(:call).once
      end
    end

    context 'when cart_id exists in params' do
      it 'uses cart_id from params' do
        expect(Carts::FindOrCreate).to receive(:call).with(cart.id.to_s).and_return(cart)
        get :index, params: { cart_id: cart.id }
        expect(session[:cart_id]).to eq(cart.id)
      end
    end

    context 'when no cart_id exists' do
      it 'creates a new cart' do
        expect(Carts::FindOrCreate).to receive(:call).with(nil).and_return(cart)
        get :index
        expect(session[:cart_id]).to eq(cart.id)
      end
    end
  end

  describe '#find_or_create_cart' do
    it 'calls Carts::FindOrCreate service' do
      expect(Carts::FindOrCreate).to receive(:call).with(nil).and_return(cart)
      controller.send(:find_or_create_cart)
    end

    it 'sets cart_id in session' do
      allow(Carts::FindOrCreate).to receive(:call).and_return(cart)
      controller.send(:find_or_create_cart)
      expect(session[:cart_id]).to eq(cart.id)
    end

    it 'returns the cart' do
      allow(Carts::FindOrCreate).to receive(:call).and_return(cart)
      result = controller.send(:find_or_create_cart)
      expect(result).to eq(cart)
    end
  end


end