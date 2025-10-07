# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  include TestHelpers

  let(:user) { make_user(password: 'password123') }
  let(:valid_credentials) { { session: { email: user.email, password: 'password123' } } }
  let(:invalid_credentials) { { session: { email: user.email, password: 'wrongpassword' } } }

  describe 'GET /login (new)' do
    it 'returns successful response' do
      get '/login'
      expect(response).to have_http_status(:success)
    end

    it 'does not require authentication' do
      get '/login'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /login (create)' do
    context 'with valid credentials' do
      it 'logs in the user successfully' do
        post '/login', params: valid_credentials
        expect(response).to redirect_to(root_path)
        expect(flash[:success]).to eq("Welcome back, #{user.name}!")
      end

      it 'handles case insensitive email' do
        upcase_credentials = { session: { email: user.email.upcase, password: 'password123' } }
        post '/login', params: upcase_credentials
        expect(response).to redirect_to(root_path)
        expect(flash[:success]).to eq("Welcome back, #{user.name}!")
      end
    end

    context 'with invalid password' do
      it 'does not log in the user' do
        post '/login', params: invalid_credentials
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash.now[:error]).to eq('Invalid email or password')
      end

      it 'renders login form again' do
        post '/login', params: invalid_credentials
        expect(response.body).to include('login')
      end
    end

    context 'with nonexistent user' do
      let(:nonexistent_credentials) { { session: { email: 'nonexistent@example.com', password: 'password123' } } }

      it 'does not log in' do
        post '/login', params: nonexistent_credentials
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash.now[:error]).to eq('Invalid email or password')
      end
    end

    context 'with empty credentials' do
      it 'handles empty password' do
        post '/login', params: { session: { email: user.email, password: '' } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash.now[:error]).to eq('Invalid email or password')
      end
    end
  end

  describe 'DELETE /logout (destroy)' do
    context 'when user is not logged in' do
      it 'handles logout gracefully' do
        delete '/logout'
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('You were already logged out.')
      end

      it 'returns JSON response for AJAX requests' do
        delete '/logout', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:success)

        data = JSON.parse(response.body)
        expect(data['success']).to be true
        expect(data['message']).to eq('Logged out successfully')
      end
    end
  end

  describe 'private methods' do
    let(:controller) { SessionsController.new }

    describe '#session_params' do
      before do
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(
            session: {
              email: 'test@example.com',
              password: 'password123',
              invalid_param: 'hack'
            }
          )
        )
      end

      it 'only permits email and password parameters' do
        permitted = controller.send(:session_params)
        expect(permitted.keys).to match_array(%w[email password])
        expect(permitted['email']).to eq('test@example.com')
        expect(permitted['password']).to eq('password123')
        expect(permitted['invalid_param']).to be_nil
      end
    end
  end

  describe 'authentication bypassing' do
    it 'skips authentication for new action' do
      get '/login'
      expect(response).to have_http_status(:success)
    end

    it 'skips authentication for create action' do
      post '/login', params: valid_credentials
      expect(response).to have_http_status(:found)
    end

    it 'skips authentication for destroy action' do
      delete '/logout'
      expect(response).to have_http_status(:found)
    end
  end

  describe 'security considerations' do
    it 'does not expose user information in URL parameters' do
      post '/login', params: valid_credentials
      expect(response.location).not_to include(user.email)
      expect(response.location).not_to include(user.id.to_s)
    end
  end
end
