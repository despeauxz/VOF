RSpec.shared_examples "associations examples" do
  it { is_expected.to belong_to(:learner_program) }
  it { is_expected.to belong_to(:assessment) }
end
