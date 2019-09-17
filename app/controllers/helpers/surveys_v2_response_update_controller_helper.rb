module SurveysV2ResponseUpdateControllerHelper
  def build_multiple_choice_response_update(response, res_id)
    question_type = "SurveyMultipleChoiceQuestion"
    return unless response["question_type"] == question_type

    option_id = response["option_id"]
    create_option_response_update(option_id,
                                  question_type, response, res_id)
  end

  def build_checkbox_response_update(response, res_id, response_ids)
    return unless response["question_type"] == "SurveyCheckboxQuestion"

    question_type = "SurveyCheckboxQuestion"

    checkbox_ids = response["checkbox_ids"]
    selected_ids = response["answer_selected_ids"]

    deleted_responses = response_ids - selected_ids.map(&:to_i)

    deleted_responses.each do |id_to_delete|
      answer_to_delete = SurveyOptionResponse.find_by(id: id_to_delete)
      answer_to_delete.destroy
    end

    ids_and_choices = checkbox_ids.zip(selected_ids)
    ids_and_choices.each do |id_and_choice|
      if id_and_choice[1] != ""
        update_check_responses(id_and_choice, SurveyOptionResponse)
      else
        create_option_response(question_type, id_and_choice[0],
                               response["question_id"], res_id)
      end
    end
  end

  def build_select_response_update(response, res_id)
    question_type = "SurveySelectQuestion"
    return unless response["question_type"] == question_type

    option_id = response["dropdown_id"]
    create_option_response_update(option_id,
                                  question_type, response, res_id)
  end

  def build_picture_option_response_update(response, res_id)
    question_type = "SurveyPictureOptionQuestion"
    return unless response["question_type"] == question_type

    option_id = response["picture_id"]
    create_option_response_update(option_id,
                                  question_type, response, res_id)
  end

  def build_picture_checkbox_response_update(response, res_id, response_ids)
    question_type = "SurveyPictureCheckboxQuestion"
    return unless response["question_type"] == question_type

    picture_checkbox_ids = response["picture_checkbox_ids"]
    selected_ids = response["answer_selected_ids"]

    deleted_responses = response_ids - selected_ids.map(&:to_i)

    deleted_responses.each do |id_to_delete|
      answer_to_delete = SurveyOptionResponse.find_by(id: id_to_delete)
      answer_to_delete.destroy
    end

    ids_and_choices = picture_checkbox_ids.zip(selected_ids)
    ids_and_choices.each do |id_and_choice|
      if id_and_choice[1] != ""
        update_check_responses(id_and_choice, SurveyOptionResponse)
      else
        create_option_response(question_type, id_and_choice[0],
                               response["question_id"], res_id)
      end
    end
  end

  def build_survey_scale_response_update(response, res_id)
    question_type = "SurveyScaleQuestion"
    return unless response["question_type"] == question_type

    value = response["value"]
    create_scale_response_update(value, question_type,
                                 response, res_id)
  end

  def build_survey_paragraph_response_update(response, res_id)
    question_type = "SurveyParagraphQuestion"
    return unless response["question_type"] == question_type

    paragraph_value = response["value"]
    create_paragraph_response_update(paragraph_value, question_type,
                                     response, res_id)
  end

  def build_survey_date_response_update(response, res_id)
    question_type = "SurveyDateQuestion"
    return unless response["question_type"] == question_type

    date = response["value"]
    date_value = date.nil? ? "" : Date.strptime(date, "%m/%d/%Y")
    create_date_response_update(date_value,
                                question_type, response, res_id)
  end

  def build_survey_time_response_update(response, res_id)
    question_type = "SurveyTimeQuestion"
    return unless response["question_type"] == question_type

    time = response["value"]
    value = time.nil? ? "" : Time.strptime(time, "%I : %M %P").strftime("%H:%M")
    create_time_response_update(value, question_type, response, res_id)
  end

  def update_items(id, model_name, value)
    value_to_update = model_name.find_by(id: id)
    value_to_update.value = value
    value_to_update.save
  end

  def save_grid_options(row_id, col_id, response, res_id)
    SurveyGridOptionResponse.create!(
      question_type: "SurveyMultigridCheckboxQuestion",
      row_id: row_id,
      col_id: col_id,
      question_id: response["question_id"],
      survey_response_id: res_id
    )
  end

  def update_grid_options(model_name, row_id, col_id, id)
    answer_to_update = model_name.find_by(id: id)
    answer_to_update.row_id = row_id
    answer_to_update.col_id = col_id
    answer_to_update.save
  end

  def update_multigrid_options(response_ids_options, response, res_id)
    unless response_ids_options.nil? || response_ids_options.nil?
      build_multi_grid_response_update(response,
                                       response_ids_options, res_id)
    end
  end

  def remove_deleted_checkboxes(deleted_responses)
    deleted_responses.each do |id_to_delete|
      answer_to_delete = SurveyGridOptionResponse.find_by(id: id_to_delete)
      answer_to_delete.destroy
    end
  end

  def update_check_responses(id_and_choice, model_name)
    if id_and_choice[1] != ""
      answer_to_update = model_name.find_by(id: id_and_choice[1])
      answer_to_update.option_id = id_and_choice[0]
      answer_to_update.save
    end
  end

  def choice_responses
    @choice_responses ||= @response["checkbox_response"]
  end

  def selected_ids
    @selected_ids ||= @response["selected_ids"]
  end

  def update_save_grid_options(id_and_choice, res_id)
    if id_and_choice[1] != ""
      update_grid_options(SurveyGridOptionResponse,
                          id_and_choice[0][0], id_and_choice[0][1],
                          id_and_choice[1])
    else
      save_grid_options(id_and_choice[0][0],
                        id_and_choice[0][1],
                        response, res_id)
    end
  end
end
