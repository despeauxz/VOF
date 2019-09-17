FactoryBot.define do
  factory :panelist do
    email { "test.test@andela.com" }
    panel
    accepted { "False" }
    factory :new_panelist, class: Panelist do
      email { "rehema.wachira@andela.com" }
    end
  end
end
