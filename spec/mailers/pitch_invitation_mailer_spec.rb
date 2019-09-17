require "rails_helper"

RSpec.describe PitchInvitationMailer, type: :mailer do
  let!(:pitch_new) { create(:pitch) }
  let!(:email) { Faker::Internet.email }
  let!(:pitch_link) { "" }
  let!(:pitch_cycle) { [{ name: "Cycle Name", cycle: "00" }] }

  describe "invite panellist" do
    let!(:mail) do
      PitchInvitationMailer.invite_panelist_to_a_pitch(email,
                                                       pitch_link,
                                                       pitch_new,
                                                       pitch_cycle)
    end

    it "renders the headers" do
      expect(mail.to).to eq([email])
      expect(mail.from).to eq(["no-reply@vof.andela.com"])
    end

    it "renders the subject" do
      expect(mail.subject).to eq("Invitation to Pre-Fellowship Pitch")
    end
  end

  describe "reschedule pitch" do
    let!(:mail) do
      PitchInvitationMailer.notify_rescheduled_pitch(email,
                                                     pitch_new.demo_date,
                                                     pitch_cycle[0][:name],
                                                     pitch_cycle[0][:cycle])
    end

    it "renders the headers" do
      expect(mail.to).to eq([email])
      expect(mail.from).to eq(["no-reply@vof.andela.com"])
    end

    it "renders the subject" do
      expect(mail.subject).to eq("Pre-fellowship Pitch Rescheduling Update")
    end
  end
end
