module SurveysV2RespondUpdateControllerHelper
  include SurveysV2ResponseUpdateControllerHelper

  def get_survey_response_id(id)
    SurveyResponse.find_by(id: id)
  end

  def build_responses_update(survey_id, res_id, response_data)
    survey_questions = get_survey_questions_update(survey_id)
    build_survey_option_responses_update(survey_questions,
                                         response_data, res_id)
    build_option_grid_responses_update(survey_questions,
                                       response_data, res_id)
    update_value_responses(survey_questions,
                           response_data, res_id)
  end

  def get_survey_questions_update(survey_id)
    survey = NewSurvey.find(survey_id)
    section_id = SurveySection.where(new_survey_id: survey.id)
    SurveyQuestion.where(survey_section_id: section_id)
  end

  def create_option_response_update(option_id,
                                    question_type, response, res_id)
    if response["id"] != ""
      answer_to_update = SurveyOptionResponse.find_by(id: response["id"])
      answer_to_update.option_id = option_id
      answer_to_update.save
    else
      create_option_response(question_type,
                             option_id, response["question_id"], res_id)
    end
  end

  def create_scale_response_update(value, question_type,
                                   response, res_id)

    unless response["id"] == ""
      return update_items(response["id"], SurveyScaleResponse,
                          value)
    end
    create_scale_response(question_type, value,
                          response["question_id"], res_id)
  end

  def create_date_response_update(value, question_type, response, res_id)
    unless response["id"] == ""
      return update_items(response["id"], SurveyDateResponse,
                          value)
    end
    create_date_response(question_type, value,
                         response["question_id"], res_id)
  end

  def create_time_response_update(value, question_type, response, res_id)
    id = response["id"]
    question_id = response["question_id"]
    if id != ""
      update_items(id, SurveyTimeResponse, value)
    else
      create_time_response(question_type, value, question_id, res_id)
    end
  end

  def create_paragraph_response_update(value,
                                       question_type, response, res_id)
    unless response["id"] == ""
      return update_items(response["id"], SurveyParagraphResponse,
                          value)
    end
    create_paragraph_response(question_type, value,
                              response["question_id"], res_id)
  end

  def build_option_grid_responses_update(survey_questions,
                                         response_data, res_id)
    survey_questions.each do |survey_question|
      response = response_data["question_#{survey_question.id}"]
      response_ids = response_data["question_#{survey_question.id}_data"]
      response_ids_options =
        response_data["question_#{survey_question.id}_data_options"]
      questionable_type = survey_question.questionable_type
      next unless (questionable_type == "SurveyOptionQuestion") && response

      build_checkbox_grid_response_update(response, res_id, response_ids)
      update_multigrid_options(response_ids_options, response, res_id)
    end
  end

  def build_survey_option_responses_update(survey_questions, response_data,
                                           res_id)
    survey_questions.each do |survey_question|
      response = response_data["question_#{survey_question.id}"]
      response_ids = response_data["question_#{survey_question.id}_data"]
      questionable_type = survey_question.questionable_type
      next unless (questionable_type == "SurveyOptionQuestion") && response

      build_multiple_choice_response_update(response, res_id)
      build_checkbox_response_update(response, res_id, response_ids)
      build_select_response_update(response, res_id)
      build_picture_option_response_update(response, res_id)
      build_picture_checkbox_response_update(response, res_id, response_ids)
    end
  end

  def build_multi_grid_response_update(response, response_ids_options, res_id)
    question_type = "SurveyMultigridOptionQuestion"
    return unless response["question_type"] == question_type

    choice_responses = response["choice_response"]

    ids_and_choices = choice_responses.zip(response_ids_options)
    ids_and_choices.each do |id_and_choice|
      unless id_and_choice[1].nil?
        update_grid_options(SurveyGridOptionResponse,
                            id_and_choice[0][0], id_and_choice[0][1],
                            id_and_choice[1])
      end
      save_grid_options(id_and_choice[0][0],
                        id_and_choice[0][1],
                        response, res_id)
    end
  end

  def build_checkbox_grid_response_update(response, res_id, response_ids)
    return unless response["question_type"] == "SurveyMultigridCheckboxQuestion"

    choice_responses = response["checkbox_response"]
    selected_ids = response["selected_ids"]
    deleted_responses = response_ids - selected_ids.map(&:to_i)
    remove_deleted_checkboxes(deleted_responses)

    selected_ids << "" until choice_responses.size == selected_ids.size
    ids_and_choices = choice_responses.zip(selected_ids)
    ids_and_choices.each do |id_and_choice|
      update_save_grid_options(id_and_choice,
                               res_id)
    end
  end

  def update_value_responses(survey_questions, response_data, res_id)
    get_response_details(survey_questions, response_data, res_id, "update")
  end
end
