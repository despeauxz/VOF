module HelpersConcern
  def update_request(params)
    put :update, params: params
  end

  def stub_learner_cookie
    allow(JWT).to receive(:decode).and_return(
      [
        {
          "UserInfo" => {
            "email" => "vof.learner@gmail.com",
            "first_name" => "Learner",
            "last_name" => "Vof",
            "name" => "Vof Learner",
            "andelan" => false,
            "learner" => true,
            "picture" => "",
            "roles" => { "Guest" => "-KXGy1EB1oimjQgFim6I" }
          }
        }
      ]
    )
  end

  def page_set_rack_session(user_obj)
    page.set_rack_session(current_user_info: user_obj)
    jwt_token = JWT.encode({}, nil, "none")
    page.driver.browser.manage.add_cookie(name: "jwt-token", value: jwt_token)
  end

  def stub_learner_session
    page_set_rack_session(
      name: "Vof Learner",
      admin: false,
      andelan: false,
      picture: "",
      email: "vof.learner@gmail.com",
      learner: true
    )
  end

  def stub_current_session_non_admin
    page_set_rack_session(
      name: "Jane Doe",
      admin: false,
      andelan: true,
      picture: ""
    )
  end

  def stub_current_session_bootcamper(user)
    page_set_rack_session(
      name: user.last_name + " " + user.last_name,
      email: user.email,
      admin: false,
      andelan: false,
      picture: "",
      learner: true
    )
  end

  def clear_session
    page.set_rack_session(current_user_info: nil)
    page.driver.browser.manage.delete_cookie("jwt-token")
  end

  def stub_camper_progress(value)
    allow(LearnerProgram).
      to receive(:update_campers_progress).and_return(value)
  end

  def stub_allow_admin
    allow(controller).to receive_message_chain(:helpers, :admin?)
  end

  def stub_export_csv
    allow(BootcampersCsvService).to receive(:generate_report).
      and_return(first_csv_header)
  end

  def wait_for_ajax
    return unless respond_to?(:evaluate_script)

    wait_until { finished_all_ajax_requests? }
  end

  def attach_spreadsheet_file(filename)
    attach_file(
      "upload_learners_file",
      "#{Rails.root}/spec/fixtures/#{filename}",
      visible: false
    )
  end

  def stub_admin_data_success
    admin_list = {
      "values": [
        {
          "id": "-random_ID",
          "name": "Test Admin",
          "email": "test-user-admin@andela.com"
        },
        {
          "id": "-another_random_ID",
          "name": "Duyile Oluwatomi",
          "email": "oluwatomi.duyile@andela.com"
        }
      ],
      "total": 2
    }

    allow_any_instance_of(AdminService).
      to receive(:get_admins).and_return(admin_list.as_json)
  end

  def upload_output_file(filename, target = "fileUpload")
    attach_file(
      target,
      "#{Rails.root}/spec/fixtures/#{filename}",
      visible: false
    )
  end

  def stub_admin_data_failure
    error_message = {
      "error": "an error occured"
    }

    allow_any_instance_of(AdminService).
      to receive(:get_admins).and_return(error_message.as_json)
  end

  def stub_current_session_admin
    page_set_rack_session(
      name: "Juliet Ezekwe",
      email: "juliet@andela.com",
      admin: true,
      andelan: true,
      picture: ""
    )
  end

  def stub_current_session_admin_two
    page_set_rack_session(
      name: "Daniel Eze",
      email: "daniel@andela.com",
      admin: true,
      andelan: true,
      picture: ""
    )
  end

  def stub_current_session_admin_panel
    page_set_rack_session(
      name: "Juliet Ezekwe",
      email: "rehema.wachira@andela.com",
      admin: true,
      andelan: true,
      picture: ""
    )
  end
end
