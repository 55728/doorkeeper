# frozen_string_literal: true

require "spec_helper"

RSpec.describe Doorkeeper::Request do
  describe ".client_authentication_method" do
    let(:request) { double }

    def auth_method(matches, returned_method = double("strategy"))
      double("client authentication method", matches_request?: matches, method: returned_method)
    end

    def configure_methods(methods)
      allow(Doorkeeper.configuration)
        .to receive(:client_authentication_methods).and_return(methods)
    end

    it "returns the method of the single matching strategy" do
      strategy = double("strategy")
      configure_methods([auth_method(false), auth_method(true, strategy)])

      expect(described_class.client_authentication_method(request)).to eq(strategy)
    end

    it "raises when more than one strategy matches the request (RFC 6749 §2.3)" do
      configure_methods([auth_method(true), auth_method(true)])

      expect { described_class.client_authentication_method(request) }
        .to raise_error(Doorkeeper::Errors::MultipleClientAuthMethods)
    end

    it "returns the fallback method when no strategy matches" do
      configure_methods([auth_method(false), auth_method(false)])

      expect(described_class.client_authentication_method(request))
        .to eq(Doorkeeper::ClientAuthentication::FallbackMethod)
    end
  end
end
