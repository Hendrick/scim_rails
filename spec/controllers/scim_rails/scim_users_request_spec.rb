require "spec_helper"

RSpec.describe ScimRails::ScimUsersController, type: :request do
  context "Basic Authorization" do
    context "with Company model table" do
      let(:company) { create(:company) }
      let(:credentials) { Base64.encode64("#{company.subdomain}:#{company.api_token}") }
      let(:authorization) { "Basic #{credentials}" }
      describe "Content-Type" do
        it "accepts scim+json" do
          expect(company.users.count).to eq 0

          post_request("application/scim+json")

          expect(request.params).to include :name
          expect(response.status).to eq 201
          expect(response.media_type).to eq "application/scim+json"
          expect(company.users.count).to eq 1
        end

        it "can not parse unfamiliar content types" do
          expect(company.users.count).to eq 0

          post_request("text/csv")

          expect(request.params).not_to include :name
          expect(response.status).to eq 422
          expect(company.users.count).to eq 0
        end
      end
    end
  end
end
