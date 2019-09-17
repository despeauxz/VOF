require "rails_helper"

module CreateRolesHelper
  def create_role_seed_data
    create_roles_helper
    assign_permissions
  end

  def create_roles_helper
    @feature = create(
      :feature,
      feature_name: "LEARNERS_PAGE"
    )
    @role = create(
      :role,
      role_name: "Admin"
    )
    @second_role = create(
      :role,
      role_name: "LFA"
    )
    @permissions = create(
      :permission,
      role_id: @second_role.id,
      feature_id: @feature.id,
      permission_name: "CAN_ADD_LEARNERS_TO_VOF",
      permission_status: true
    )

    @user_role = create(
      :user_role, role_id: @role.id
  )
  end

  def assign_permissions
    @permissions = create(
      :permission,
      role_id: @role.id,
      feature_id: @feature.id,
      permission_name: "CAN_ADD_LEARNERS_TO_VOF",
      permission_status: false
    )
  end
end
