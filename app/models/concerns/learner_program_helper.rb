module LearnerProgramHelper
  def ongoing?
    cycle_center.end_date && cycle_center.end_date >= Date.today
  end

  def active_lfa
    if week_two_facilitator.email == "unassigned@andela.com"
      return week_one_facilitator
    end

    week_two_facilitator
  end

  def active_learner?(learner)
    decision = learner.decision_one
    ["In Progress", "Advanced"].include?(decision)
  end
end
