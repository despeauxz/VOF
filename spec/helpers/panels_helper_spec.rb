module PanelsHelperSpec
  def redirect_to_index_path_if_not_admin(action, pitch_id, panel_id)
    controller.helpers.stub(:admin?) { false }

    if action == "edit"
      get :edit, params: { pitch_id: pitch_id, id: panel_id }
    end
    if action == "destroy"
      delete :destroy, params: { pitch_id: pitch_id, id: panel_id }
    end
    expect(response).to redirect_to(index_path)
  end

  def visit_panels(pitch_id, program_name)
    visit(index_path)
    find("a.dropdown-input").click

    find("ul#index-dropdown li a.dropdown-link", text: program_name).click
    find("img.proceed-btn").click
    visit(pitch_index_path)

    visit(pitch_panels_path(pitch_id))
  end

  def create_panel(panel_name, panellist_email)
    visit_panels(@pitch.id, @program.name)
    find("#new-panel-btn").click
    fill_in("invite-panelist", with: panel_name.to_s)
    find("#learner-select-option").click
    find("#learner-options-wrapper", match: :first).click
    find("#learner-options-wrapper", match: :first).click
    find("#learner-options-wrapper", match: :first).click
    find("#learner-options-wrapper", match: :first).click
    find("div#learner-select-option").click
    fill_in("invite-panelist2", with: panellist_email.to_s)
    find(".add-invitee-icon").click
    find(".create-panel-btn").click
  end
end
