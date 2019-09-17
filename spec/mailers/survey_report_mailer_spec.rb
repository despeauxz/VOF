require "rails_helper"

RSpec.describe SurveyReportMailer, type: :mailer do
  describe "notify" do
    let!(:survey_new) { create(:survey) }
    let!(:email) { Faker::Internet.email }
    let!(:survey_link) { "" }

    let!(:mail) do
      SurveyReportMailer.survey_report(email, survey_link, survey_new)
    end

    it "renders the headers" do
      expect(mail.to).to eq([email])
      expect(mail.from).
        to eq(["no-reply@vof.andela.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).
        to match("You are cordially invited to view")
    end
  end
end
