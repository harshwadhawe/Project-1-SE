require 'rails_helper'

RSpec.describe ApplicationController, type: :request do
  include TestHelpers
  
  let(:user) { make_user }
  let(:jwt_token) { user.generate_jwt_token }

  describe 'JWT token handling' do
    let(:controller) { ApplicationController.new }
    
    it 'extracts JWT token from signed cookies' do
      allow(controller).to receive(:cookies).and_return(
        double(signed: { jwt_token: 'test_token' })
      )
      
      expect(controller.send(:jwt_token)).to eq('test_token')
    end
    
    it 'memoizes JWT token' do
      cookies_double = double(signed: { jwt_token: 'test_token' })
      allow(controller).to receive(:cookies).and_return(cookies_double)
      
      expect(cookies_double.signed).to receive(:[]).with(:jwt_token).once.and_return('test_token')
      
      # Call jwt_token multiple times
      controller.send(:jwt_token)
      controller.send(:jwt_token)
    end
  end

  describe 'current_user method' do
    let(:controller) { ApplicationController.new }
    
    it 'returns user when valid JWT token present' do
      allow(controller).to receive(:jwt_token).and_return(jwt_token)
      allow(User).to receive(:decode_jwt_token).with(jwt_token).and_return(user)
      
      expect(controller.send(:current_user)).to eq(user)
    end
    
    it 'returns nil when no JWT token' do
      allow(controller).to receive(:jwt_token).and_return(nil)
      
      expect(controller.send(:current_user)).to be_nil
    end
    
    it 'returns nil when JWT token is invalid' do
      allow(controller).to receive(:jwt_token).and_return('invalid_token')
      allow(User).to receive(:decode_jwt_token).with('invalid_token').and_return(nil)
      
      expect(controller.send(:current_user)).to be_nil
    end
    
    it 'memoizes current_user' do
      allow(controller).to receive(:jwt_token).and_return(jwt_token)
      expect(User).to receive(:decode_jwt_token).once.and_return(user)
      
      # Call current_user multiple times
      first_call = controller.send(:current_user)
      second_call = controller.send(:current_user)
      
      expect(first_call).to eq(user)
      expect(second_call).to eq(user)
    end
  end

  describe 'parameter sanitization' do
    let(:controller) { ApplicationController.new }
    
    before do
      allow(controller).to receive(:params).and_return(
        ActionController::Parameters.new(
          email: 'test@example.com',
          password: 'secret123',
          password_confirmation: 'secret123',
          authenticity_token: 'token123',
          name: 'Test User'
        )
      )
    end
    
    it 'removes sensitive parameters from logs' do
      sanitized = controller.send(:sanitized_params)
      
      expect(sanitized).not_to include('secret123')
      expect(sanitized).not_to include('token123')
      expect(sanitized).to include('test@example.com')
      expect(sanitized).to include('Test User')
    end
    
    it 'truncates long parameter strings' do
      long_params = ActionController::Parameters.new(
        data: 'x' * 1000
      )
      allow(controller).to receive(:params).and_return(long_params)
      
      sanitized = controller.send(:sanitized_params)
      expect(sanitized.length).to be <= 500
    end
  end

  describe 'authentication behavior with real routes' do
    it 'allows access to public routes' do
      get "/builds"
      expect(response).to have_http_status(:success)
    end
    
    it 'allows access to parts without authentication' do
      get "/parts"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'browser compatibility' do
    it 'works with modern browsers' do
      get "/builds", headers: { 
        'User-Agent' => 'Mozilla/5.0 (compatible; modern-browser)' 
      }
      expect(response).to have_http_status(:success)
    end
  end
end