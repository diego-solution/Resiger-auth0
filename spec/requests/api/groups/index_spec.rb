# frozen_string_literal: true

describe "Group APIs", type: :request  do
  describe "Get #index" do
    context "when error" do
      after do
        expect(json_response[:code]).not_to eql RESPONSE_CODE[:success]
      end

      it "render unauthorized error when un-authenticated" do
        skip "TODO "
        # get api_base_url + "/groups", params: {}, headers: request_headers
        # json_data = json_response[:data]
        # expect(json_data.blank?).to eql true
        # expect(json_response[:code]).to eql RESPONSE_CODE[:unauthorized]
        # expect(json_response[:message]).to include I18n.t("api.errors.not_authenticated")
      end
    end
  end
end
