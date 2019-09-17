module MainHelperSpec
  def list_of_all_frameworks
    frameworks = assigns(:frameworks)
    expect(frameworks.length).to eq(3)
    expect(frameworks[0][1]).to eq("Values Alignment")
    expect(frameworks[1][1]).to eq("Output Quality")
    expect(frameworks[2][1]).to eq("Feedback")
  end

  def validate_for_admin_user(cycle, value)
    allow_any_instance_of(ApplicationHelper).to receive(
      :admin?
      ).and_return true

    expect(can_edit_scores?(user.user_info[:id],
                            cycle)).to be value
  end

  def validate_presence_of_models
    is_expected.to validate_presence_of(:name)
    is_expected.to validate_presence_of(:context)
    is_expected.to validate_presence_of(:description)
    is_expected.to validate_presence_of(:framework_criterium_id)
  end

  def belongs_to_models
    is_expected.to belong_to(:learner_program)
    is_expected.to belong_to(:phase)
    is_expected.to belong_to(:assessment)
    is_expected.to belong_to(:impression)
  end

  def validate_presence_of_attributes(attributes)
    attributes.each do |attribute|
      is_expected.to validate_presence_of(attribute)
    end
  end
end
