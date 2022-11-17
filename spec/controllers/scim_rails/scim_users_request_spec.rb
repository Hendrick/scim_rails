require "spec_helper"

RSpec.describe ScimRails::ScimUsersController, type: :request do

  def post_request(content_type = "application/scim+json")
    # params need to be transformed into a string to test if they are being parsed by Rack

    post "/scim/v2/Users",
         params: {
           name: {
             givenName: "New",
             familyName: "User",
           },
           emails: [
             {
               value: "new@example.com",
             },
           ],
         }.to_json,
         headers: {
           'Authorization': authorization,
           'Content-Type': content_type,
         }
  end

  context "Basic Authorization" do

    context "with Company model table" do
      let(:company) { create(:company) }
      let(:credentials) { Base64::encode64("#{company.subdomain}:#{company.api_token}") }
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
          byebug

          post_request("text/csv")

          expect(request.params).not_to include :name
          expect(response.status).to eq 422
          expect(company.users.count).to eq 0
        end
      end
    end

    context "with app SCIM authentication ENV variables set" do

      before do
        @cached_subdomain = ENV['SCIM_USERNAME']
        @cahced_api_token = ENV['SCIM_PASSWORD']

        ENV['SCIM_USERNAME'] = 'test_username'
        ENV['SCIM_PASSWORD'] = 'test_password'
      end

      let(:credentials) { Base64::encode64("#{'test_username'}:#{'test_password'}") }
      let(:authorization) { "Basic #{credentials}" }

      describe "Content-Type" do
        it "accepts scim+json" do
          post_request("application/scim+json")

          expect(request.params).to include :name
          expect(response.status).to eq 201
          expect(response.media_type).to eq "application/scim+json"
          expect(User.count).to eq 1
        end

        it "can not parse unfamiliar content types" do
          expect(User.count).to eq 0

          post_request("text/csv")

          expect(request.params).not_to include :name
          expect(response.status).to eq 422
          expect(User.count).to eq 0
        end
      end


      after do
        ENV['SCIM_USERNAME'] = @cached_subdomain
        ENV['SCIM_PASSWORD'] = @cahced_api_token
      end
    end
  end

  # context "OAuth Bearer Authorization" do

  #   let(:company) { create(:company) }
  #   let(:credentials) { Base64::encode64("#{company.subdomain}:#{company.api_token}") }
  #   let(:authorization) { "Basic #{credentials}" }

  #   context "with valid token" do
  #     let(:authorization) { "Bearer #{company.api_token}" }

  #     it "supports OAuth bearer authorization and succeeds" do
  #       expect { post_request }.to change(company.users, :count).from(0).to(1)

  #       expect(response.status).to eq 201
  #     end
  #   end

  #   context "with invalid token" do
  #     let(:authorization) { "Bearer #{SecureRandom.hex}" }

  #     it "The request fails" do
  #       expect { post_request }.not_to change(company.users, :count)

  #       expect(response.status).to eq 401
  #     end
  #   end
  # end
end
