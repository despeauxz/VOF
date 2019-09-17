module SurveyResponseHelper
  def submission_succeeds(survey, survey_responses)
    post :create, params: { survey_id: survey.id,
                            survey_responses: survey_responses.to_json },
                  headers: { "Content-Type": "multipart/form-data" }
    expect(response.body).to include("Submitted")
    expect(response.status).to eq(201)
  end

  def update_succeeds(survey, survey_responses, survey_responses_id)
    put :update, params: { survey_id: survey.id,
                           survey_responses: survey_responses.to_json,
                           survey_responses_id: survey_responses_id },
                 headers: { "Content-Type": "multipart/form-data" }
    expect(response.status).to eq(201)
  end

  def update_fails(survey_responses, survey_responses_id)
    put :update, params: { survey_id: "",
                           survey_responses: survey_responses.to_json,
                           survey_responses_id: survey_responses_id }
    expect(response.status).to eq(400)
  end

  def submission_fails(survey, survey_responses)
    post :create, params: { survey_id: survey.id,
                            survey_responses: survey_responses.to_json },
                  headers: { "Content-Type": "multipart/form-data" }
    expect(response.status).to eq(400)
  end
end
