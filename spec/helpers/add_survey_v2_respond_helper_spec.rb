def create_questions
  [
    create(:survey_question,
           survey_section_id: survey_section.id,
           questionable_id: scale_question.id,
           questionable_type: "SurveyScaleQuestion"),
    create(:survey_question,
           survey_section_id: survey_section.id,
           questionable_id: time_question.id,
           questionable_type: "SurveyTimeQuestion"),
    create(:survey_question,
           survey_section_id: survey_section.id,
           questionable_id: date_question.id,
           questionable_type: "SurveyDateQuestion"),
    create(:survey_question,
           survey_section_id: survey_section.id,
           questionable_id: paragraph_question.id,
           questionable_type: "SurveyParagraphQuestion"),
    create_list(:survey_question, 7,
                survey_section_id: survey_section.id,
                questionable_id: option_question.id,
                questionable_type: "SurveyOptionQuestion"),
    create(:survey_option,
           survey_option_question_id: option_question.id)
  ]
end

def checkbox_helper(id)
  {
    checkbox_ids: [option_question.id.to_s, option_question.id.to_s],
    question_id: 10,
    answer_selected_ids: [id.to_s, ""],
    question_10_data: [1],
    question_type: "SurveyCheckboxQuestion"
  }
end

def picture_checkbox_helper(id)
  {
    picture_checkbox_ids: [option_question.id.to_s, option_question.id.to_s],
    question_id: 11,
    answer_selected_ids: [id.to_s, ""],
    question_11_data: [1],
    question_type: "SurveyPictureCheckboxQuestion"
  }
end

def multichoice_grid_helper
  {
    choice_response: [[option_question.id, option_question.id], [2, 3]],
    question_id: 8,
    id: 1,
    question_8_data_options: [1],
    question_type: "SurveyMultigridOptionQuestion"
  }
end

def checkbox_grid_helper
  {
    checkbox_response: [[option_question.id, option_question.id], [2, 3]],
    question_id: 9,
    selected_ids: ["", ""],
    question_9_data: [1],
    question_type: "SurveyMultigridCheckboxQuestion"
  }
end
