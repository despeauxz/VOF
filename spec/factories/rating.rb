FactoryBot.define do
  factory :rating do
    panelist
    learners_panel
    ui_ux { 3 }
    api_functionality { 3 }
    error_handling { 3 }
    project_understanding { 3 }
    presentational_skill { 3 }
    decision { "Yes" }
    comment Faker::Lorem.sentence
    factory :rating1, class: Rating do
      decision { "No" }
    end
  end
end
