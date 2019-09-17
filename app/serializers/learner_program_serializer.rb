class LearnerProgramSerializer < ActiveModel::Serializer
  attributes :id, :decision_one, :decision_two, :progress,
             :overall_average, :value_average, :output_average,
             :feedback_average, :camper_id, :program_id, :dlc_stack_id,
             :proficiency_id, :program_year_id, :cycle_center_id,
             :week_one_facilitator_id, :week_two_facilitator_id
  belongs_to :bootcamper, foreign_key: :camper_id
end
