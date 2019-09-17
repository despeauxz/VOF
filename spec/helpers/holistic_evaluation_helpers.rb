module HolisticEvaluationHelpers
  extend self

  def evaluation_details
    [{
      average: 2,
      created_at: {
        date: "February  5, 2018",
        time: "21:31:37 GMT"
      },
      details: {
        "EPIC": {
          comment: "Top quality EPIC nature at all times",
          score: 2
        }
      }
    }]
  end

  def post_learner_scores(evaluation)
    post :create,
         params:
           {
             id: learner_program.camper_id,
             learner_program_id: learner_program.id,
             holistic_evaluation: evaluation
           },
         xhr: true
  end
end
