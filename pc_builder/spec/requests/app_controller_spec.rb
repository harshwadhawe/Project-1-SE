# frozen_string_literal: true
require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def ok
      render plain: "ok"
    end
    def boom
      raise StandardError, "kaboom"
    end
    def missing
      raise ActiveRecord::RecordNotFound, "gone"
    end
    def needs_param
      raise ActionController::ParameterMissing, :important_param
    end
  end

  before do
    routes.draw do
      get "ok"          => "anonymous#ok"
      get "boom"        => "anonymous#boom"
      get "missing"     => "anonymous#missing"
      get "needs_param" => "anonymous#needs_param"
    end
  end

  describe "jwt_token variants & memoization" do
    it "reads from cookies.signed with symbol key" do
      allow(controller).to receive(:cookies).and_return(double(signed: { jwt_token: "tok1" }))
      expect(controller.send(:jwt_token)).to eq("tok1")
    end

    it "reads from cookies.signed with string key" do
      allow(controller).to receive(:cookies).and_return(double(signed: { "jwt_token" => "tok2" }))
      expect(controller.send(:jwt_token)).to eq("tok2")
    end

    it "memoizes the token" do
      signed = { jwt_token: "tok3" }
      allow(controller).to receive(:cookies).and_return(double(signed: signed))
      expect(controller.send(:jwt_token)).to eq("tok3")
      signed[:jwt_token] = "changed"
      expect(controller.send(:jwt_token)).to eq("tok3") # still memoized
    end
  end

  describe "authenticate_user! branches" do
    it "redirects to login for HTML when unauthenticated" do
      allow(controller).to receive(:current_user).and_return(nil)
      get :ok
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(/login/)
      expect(flash[:alert]).to be_present
    end

    it "returns 401 JSON when unauthenticated" do
      allow(controller).to receive(:current_user).and_return(nil)
      request.headers["ACCEPT"] = "application/json"
      get :ok
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Authentication required")
    end

    it "allows when authenticated" do
      allow(controller).to receive(:current_user).and_return(double(id: 1, email: "x@y.z"))
      get :ok
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("ok")
    end
  end

  describe "rescue handlers (stub current_user so actions execute)" do
    before { allow(controller).to receive(:current_user).and_return(double(id: 1, email: "x@y.z")) }

    it "handle_standard_error → 500 HTML" do
      get :boom
      expect(response).to have_http_status(500)
      expect(response.content_type).to match(/html/)
    end

    it "handle_standard_error → 500 JSON" do
      request.headers["ACCEPT"] = "application/json"
      get :boom
      expect(response).to have_http_status(500)
      expect(JSON.parse(response.body)["error"]).to eq("Internal server error")
    end

    it "handle_record_not_found → 404 HTML" do
      get :missing
      expect(response).to have_http_status(404)
      expect(response.content_type).to match(/html/)
    end

    it "handle_record_not_found → 404 JSON" do
      request.headers["ACCEPT"] = "application/json"
      get :missing
      expect(response).to have_http_status(404)
      expect(JSON.parse(response.body)["error"]).to eq("Record not found")
    end

    it "handle_parameter_missing → redirect_back (HTML)" do
      get :needs_param
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to("/")
    end

    it "handle_parameter_missing → 400 JSON" do
      request.headers["ACCEPT"] = "application/json"
      get :needs_param
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body)["error"]).to match(/param is missing/i)
    end
  end

  describe "log_performance around_action executes" do
    it "runs and returns ok" do
      allow(controller).to receive(:current_user).and_return(double(id: 1, email: "x@y.z"))
      get :ok
      expect(response).to have_http_status(:ok)
    end
  end

  describe "sanitized_params" do
    it "filters sensitive keys and truncates long strings" do
      long = "x" * 2000
      params_struct = ActionController::Parameters.new(
        email: "a@b.c",
        password: "secret",
        password_confirmation: "secret",
        authenticity_token: "tok",
        nested: { arr: [1, 2, 3], long: long }
      )
      allow(controller).to receive(:params).and_return(params_struct)

      s = controller.send(:sanitized_params)
      expect(s).to include("a@b.c")
      expect(s).not_to include("secret")
      expect(s).not_to include("tok")
      expect(s.length).to be <= 500
    end
  end
end
