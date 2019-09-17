FactoryBot.define do
  factory :survey_grid_option_response do
    trait :multigrid_option do
      row_id 1
      col_id 5
      question_id 15
      question_type "SurveyMultigridOptionQuestion"
    end

    trait :multigrid_checkbox do
      row_id 1
      col_id 5
      question_id 16
      question_type "SurveyMultigridCheckboxQuestion"
    end
  end
end
