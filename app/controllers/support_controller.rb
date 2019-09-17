class SupportController < ApplicationController
  skip_before_action :redirect_non_andelan
  include SupportControllerHelper

  before_action :set_user, only: [:destroy]

  def index
    support = SupportService.new
    support_data = support.get_support_data
    user_type = helpers.authorized_learner? ? "learner" : "user"
    @faqs = support_data["faqs"][user_type]
    @resources = support_data["resources"][user_type]
    @faqs = search if params[:search]
    @roles = Role.includes(:permissions).all
  end

  def get_users
    return redirect_to index_path unless helpers.admin?

    @users = UserRole.joins(:role).select(
      "roles.role_name, user_roles.id, user_roles.email"
    ).order("id")
    render json: { users: @users }
  end

  def role_permissions
    feature_ids = Feature.pluck(:id)
    role = Role.find(params[:id])
    role_permissions = role.permissions
    if feature_ids.any?
      @permissions = feature_ids.map do |feature_id|
        feature = Feature.find_by(id: feature_id)
        permissions = role_permissions.select do |permission|
          permission.feature_id == feature_id
        end
        {
          feature: feature[:feature_name],
          role: role.role_name,
          role_id: role.id,
          permissions: permissions
        }
      end
      render json: @permissions, status: 200
    end
  rescue StandardError => e
    Bugsnag.custom_notify(e)
    render json: {
      message: "An error occurred",
      error: e
    }, status: 400
  end

  def assign_permisions
    id = params[:permission_id]
    permission_status = params[:permission_status]
    begin
      return redirect_to index_path unless helpers.admin?

      @permission_status = Permission.where(id: id).
                           update(permission_status: permission_status)
      @role_for_permission = Permission.where(role_id: params[:id])
      @permission_set = @role_for_permission.
                        select { |x| x.permission_status == true }.any?
      render json: { permission_status: @permission_set, status: 200 }
    rescue StandardError => e
      Bugsnag.custom_notify(e)
      render json: { error: "An error occurred, try again", status: 400 }
    end
  end

  def destroy
    return redirect_to index_path unless helpers.admin?

    @user.destroy
    render json: { message: "User successfully deleted", status: 200 }
  rescue StandardError => e
    Bugsnag.custom_notify(e)
    render json: { error: "An error occurred", status: 400 }
  end

  private

  def set_user
    @user = UserRole.find_by(id: params[:id])
    if @user.blank?
      render json: { error: "Sorry, that user does not exist", status: 404 }
    end
  end

  def search
    answers_check = support_data_search(@faqs, "answer")
    questions_check = support_data_search(@faqs, "question")
    questions_check.concat(answers_check).uniq
  end

  def support_data_search(category, section)
    normalized_search_term = params[:search].downcase
    category.select do |item|
      item[section].downcase.include? normalized_search_term
    end
  end
end
