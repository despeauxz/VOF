require "rails_helper"

RSpec.describe SurveyResponseNotificationJob, type: :job do
  include ActiveJob::TestHelper

  before :all do
    program = create(:program)
    create(:new_survey)
    center = create(:center, name: "Nairobi", country: "Kenya")
    cycle = create(:cycle, cycle: 35)
    cycle_center = create(
      :cycle_center,
      center: center,
      cycle: cycle,
      program_id: program.id
    )
    create(
      :learner_program,
      program_id: program.id,
      cycle_center: cycle_center,
      decision_one: "Advanced",
      decision_two: "Accepted"
    )
  end

  subject(:job) { described_class.perform_later }

  it "successfully queue job" do
    expect { job }.
      to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "use a default queue" do
    expect(SurveyResponseNotificationJob.new.queue_name).to eq("default")
  end

  it "executes perform" do
    perform_enqueued_jobs { job }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
    LearnerProgram.last.destroy
    Bootcamper.last.destroy
  end
end
