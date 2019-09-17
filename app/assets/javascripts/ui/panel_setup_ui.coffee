class Panel.PanelSetup.UI
  constructor: (@api) ->
    @deleteConfirmationModal = new Modal.App('#panel-delete-confirmation-modal', 500, 500, 255, 255)
    @panelNames = []
    @allPitchLfaEmails = []
    @panels = []
    @allSelectedInPanel = []
    @eligibleLearners = []
    @panelLearners = []
    @selectedLearners = []
    @pitchLfaEmail = []
    @existingPanelists = []
    @existingLearners = []
    @newLearners = []
    @pagination = new PaginationControl.UI()
    @summaryPagination = new PaginationControl.UI()
    @summaryContentCount = 0
    @contentPerPage = 14
    @summaryContentPerPage = 10
    @loaderUI = new Loader.UI()

  initialize: ->
    @handleSavePanels()
    @addPanel()
    @fetchPitchLearnerAverage()
    @getAllPanels()
    @toggleFilter()
    @showFilteredLearnerAverage()
    @closeFilterModal()

  toastMessage: (message, status) =>
    $('.toast').messageToast.start(message, status)

  flashErrorMessage: (message) =>
    @toastMessage(message, 'error')

  flashSuccessMessage: (message) =>
    @toastMessage(message, 'success')

  getAllPanels: =>
    self = @
    if pageUrl[1] == 'pitch' && pageUrl[3] == 'panels' && pageUrl.length == 4
      @loaderUI.show()
      @api.getPanelData(self.contentPerPage, self.pagination.page)
        .then((data) -> (
          self.panelsCount = data.data_count
          self.admin = data.admin
          self.panelist = data.panelist
          self.is_past_pitch = data.is_past_pitch
          panelsData = data.paginated_data
          self.pagination.initialize(
            self.panelsCount, self.api.getPanelData,
            self.populatePanels, self.contentPerPage,
            {}, ".pagination-control.panels-pagination"
          )
          self.populatePanels(panelsData)
          self.loaderUI.hide()
        ))

  populatePanels: (panelsData) =>
    self = @
    $("#panels-count").html self.panelsCount
    $(".panels-grid").html("")
    if self.admin && !self.is_past_pitch
      $(".panels-grid").html("").append(
        "
        <a href='/pitch/#{pageUrl[2]}/panels/new' >
        <div class='add-new-panel-card' id='new-panel-btn'>
          <div class='add-icon'></div>
            <p>Add a new Panel</p>
        </div>
      </a>
      "
      )

    if self.panelsCount == 0
      if self.admin && !self.is_past_pitch
        $(".dashboard-main-section#panel-section").html("").append(
          "<div class='empty-panel'>
          <div class='empty-image'></div>
          <p>No Panels have been created</p>
          <a href='/pitch/#{pageUrl[2]}/panels/new' class='new-panel-btn' id='new-panel-btn'> Add a new Panel</a>
          </div>"
        )
      else if self.admin && self.is_past_pitch
        $(".dashboard-main-section#panel-section").html("").append(
          "<div class='empty-panel'>
          <div class='empty-image'></div>
          <p>You cannot create a panel in a past pitch</p>
          <button class='new-panel-btn disabled' disabled id='new-panel-btn'> Add a new Panel</button>
          </div>"
        )
      else
        $(".dashboard-main-section").html("").append(
          "<div class='empty-panel'>
          <div class='empty-image'></div>
          <p>No Panels have been created</p>
          </div>"
        )

    panelsData.forEach((panel) ->
      self.populatePanelsCard(panel)
    )
    self.showEditPanel()
    self.openDeleteConfirmationModal()
    
  populatePanelsCard: (panel) ->
    if @admin
      panelDetails = """
      <div class="panel-card">
        <div class="body" onclick='window.location = "panels/#{panel.id}"'>
          <div class="title">#{panel.panel_name}</div>
          <div class="time">
            <div class="eye-icon"></div>
            <span id="remaining-time">#{moment(Date.parse(panel.created_at)).fromNow()}</span>
          </div>
        </div>
          <div class="panel-card-footer">
          <div class="more-icon">
            <ul class="dropdown-option">
              <li class="dropdown-item edit" data-id="#{panel.id}"><a class="edit">Edit Panel</a></li>
              <li data-id="#{panel.id}" class="dropdown-item delete">
                  <a class="delete">Delete Panel</a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    """
    else
      panelDetails = """
      <div class="panel-card">
        <div class="body" onclick='window.location = "panels/#{panel.id}"'>
          <div class="title">#{panel.panel_name}</div>
          <div class="time">
            <div class="eye-icon"></div>
            <span id="remaining-time">#{moment(Date.parse(panel.created_at)).fromNow()}</span>
          </div>
        </div>
      </div>
    """
    $(".panels-grid").append(panelDetails)

  showEditPanel: () ->
    self = @
    $('.dropdown-item.edit').off 'click'
    $('.dropdown-item.edit').on 'click', ->
      self.panel_id = $(this)[0].dataset.id
      self.api.editPanel(self.panel_id, self.flashErrorMessage)
      .then((data) -> (
        if data.error
          self.flashErrorMessage(data.error)
        else
          window.location.href = "#{location.protocol}//#{location.host}/pitch/#{pageUrl[2]}/panels/#{self.panel_id}/edit"
      ))

  openDeleteConfirmationModal: ->
    self = @
    $(".dropdown-item.delete").off 'click'
    $(".dropdown-item.delete").on 'click', ->
      self.panelId = $(this)[0].dataset.id
      self.deleteConfirmationModal.open()
      self.closeDeleteConfirmationModal()
      self.deletePanel(self.panelId)

  closeDeleteConfirmationModal: ->
    self = @
    $('.close-delete-modal, .cancel-btn').on 'click', ->
      self.deleteConfirmationModal.close()

  deletePanel: (panelId) ->
    self = @
    $('#confirm-delete-panel').off 'click'
    $('#confirm-delete-panel').on 'click', ->
      self.api.deletePanel(panelId, self.flashErrorMessage)
        .then((data) -> (
          if data.error
            self.flashErrorMessage(data.error)
            self.deleteConfirmationModal.close()
          else
            self.flashSuccessMessage(data.message)
            self.deleteConfirmationModal.close()
            window.location.reload()
        ))

  pitchPanel: () ->
    self = @
    self.addPitchPanelist()
    self.onTogglePanelViews()
    self.addPanel()
    self.handleSavePanels()
    @handleBackButton()
    pitch_id = pageUrl[2]
    @loaderUI.show()
    @api.getAllCampersInPitch(pitch_id, self.flashErrorMessage)
      .then((data) -> (
        pitch_learners = data.learner_programs.map (learners) -> learners.bootcamper
        self.panelLearners = pitch_learners
        self.allPitchLfaEmails = data.panelists.map (panelists) -> panelists.email
        self.selectPanelLearners()

        self.panelNames = data.panel_names.map (name)  -> name.panel_name
        self.loaderUI.hide()
      )
    )

  onTogglePanelViews: ->
    $('#form-btn').addClass('button-background-color').click(->
      $('.form').show()
      $('.preview').hide()
    )

    $('#preview-btn').click( ->
      $('.form').hide()
      $('.preview').show()
    )

    $('.view-btn-1').click(->
      $(this).addClass('button-background-color').siblings().removeClass('button-background-color')
    )

  selectPanelLearners: =>
    self = @
    learners = ''
    self.panelLearners.forEach((learner) ->
      already_added = self.selectedLearners.find((panel_learner) ->
        panel_learner.id == learner.camper_id
      )
      already_selected = self.allSelectedInPanel.find((panel_learner) ->
        panel_learner.id == learner.camper_id
      )
      return if already_added
      return if already_selected

      learners += """
        <div class="panel-learners-content">
          <span>#{learner.first_name} #{learner.last_name}</span>
          <input type="hidden" value="#{learner.camper_id}" data-learner_name="#{learner.first_name} #{learner.last_name}">
        </div>
      """
    )
    $(".panel-learners-display").html(learners)
    $('.panel-learners-content').on 'click', -> (
      self.selectLearnerForPanel($(this)
      ))
    self.displayPopulatePanel()

  displayPopulatePanel:  ->
    $("#learner-select-option").off("click").click ->
        $(".panel-options-wrapper").css("max-height","14rem")
        if $('#learner-options-wrapper').css('display') is 'block'
          $('#learner-options-wrapper').hide()
        else
          $('#learner-options-wrapper').show()

  update: (panel_id) ->
    @editPanel(panel_id)
    @handleBackButton()

  editPanel: (panel_id) ->
    self = @
    self.addPitchPanelist()
    @loaderUI.show()
    self.api.editPanel(panel_id, self.flashErrorMessage)
      .then((data) -> (
          self.newLearners = data.new_learners
          self.panelLearners = data.learners
          self.existingPanelists = data.panelists
          self.mapNewLearners()
          self.mapPanelLearners(self.panelLearners)
          self.mapExistingPanelists(self.existingPanelists)
          self.allPitchLfaEmails = data.allPitchPanelists
          self.handleEditSubmit()
          self.populateLearners()
          self.loaderUI.hide()
      ))

  mapNewLearners: => 
    self = @
    self.newLearners.map (learner) ->
      first_name = learner.bootcamper.first_name
      last_name = learner.bootcamper.last_name
      id = learner.bootcamper.camper_id 
      name = first_name + ' ' + last_name

      learners_obj = {
        id: id,
        name: name,
        first_name: first_name,
        last_name: last_name
      }

      self.eligibleLearners.unshift(learners_obj)

  populateLearners: =>
    self = @
    learners = ''
    self.eligibleLearners.forEach((learner) ->
      already_added = self.selectedLearners.find((panel_learner) ->
        panel_learner.id == learner.id
      )

      return if already_added
      learners += """
        <div class="panel-learners-content">
          <span>#{learner.name}</span>
          <input type="hidden" value="#{learner.id}" data-learner_name="#{learner.name}">
        </div>
      """
    )
    $(".panel-learners-display").html(learners)
    $('.panel-learners-content').on 'click', -> (
      self.selectLearnerForPanelEdit($(this)
      ))
    self.displayEditPopulatePanel()
    self.displaySelectedLearnerToEdit(self.selectedLearners)

  displayEditPopulatePanel:  ->
    $('html').on 'click', (e) ->
      if (not $(e.target).is('#learner-select-option'))
        $('#learner-options-wrapper').hide()
      $('#learner-select-option').on 'click', (e) ->
        e.stopPropagation()

    $("#learner-select-option").off("click").click ->
      $(".panel-options-wrapper").css("max-height","14rem")
      if $('#learner-options-wrapper').css('display') is 'block'
        $('#learner-options-wrapper').hide()
      else
        $('#learner-options-wrapper').show()

  selectLearnerForPanelEdit: (target) ->
    self = @
    learners_obj = {}
    learner_name = target.find('input').data("learner_name")
    learner_id = target.find('input').val()
    learners_obj = {
      id: learner_id,
      name: learner_name
    }
    self.selectedLearners.unshift(learners_obj)
    self.eligibleLearners = self.eligibleLearners.filter((learner) -> learners_obj.id != learner.id)
    self.populateLearners()

  displaySelectedLearnerToEdit: (panel_learners) ->
    self = @
    learners = ''

    panel_learners.map (panel_learner) ->
      learners += """
        <li id = #{panel_learner.id}>
          #{panel_learner.name }  
          <span class="rated_learner">#{if panel_learner.rated then ' (rated)' else ""}<span>
          <span data-target="#{panel_learner.id}" class="selected-learner-close">&times;</span>
        </li>
      """
    $(".selected-learners").html(learners)
    $('.selected-learners .selected-learner-close').on 'click', -> (
      self.removeLearnerForEdit($(this))
    )
    learners = ""

  mapPanelLearners: (data) ->
    self = @
    data.map (learner) ->
      first_name = learner.bootcamper.first_name
      last_name = learner.bootcamper.last_name
      id = learner.bootcamper.camper_id 
      rated= learner.rated 
      name = first_name + ' ' + last_name
      learners_obj = {
        id: id,
        name: name,
        rated: rated,
      }
      
      self.selectedLearners.unshift(learners_obj)


  removeLearnerForEdit: (target) ->
    self = @
    remove_learner = target.data('target')
    removedLearner = self.selectedLearners.filter((learner) -> learner.id == remove_learner)
    return self.flashErrorMessage "You cannot remove a rated learner" unless !removedLearner[0].rated
    self.selectedLearners = self.selectedLearners.filter((learner) -> learner.id != remove_learner)
    self.eligibleLearners.unshift(removedLearner[0])
    target.remove()
    self.populateLearners()


  mapExistingPanelists: ->
    self = @
    self.existingPanelists.map((panelist) -> 
      self.pitchLfaEmail.push(panelist.email)
    )
    self.displayPanelistEmail(self.pitchLfaEmail)

  addPitchPanelist: ->
    self = @
    $('.invite-panelist2').on 'keypress', (e) ->
      if (e.which == 13 )
        e.preventDefault()
        self.acceptPanelistInputHelper(self.pitchLfaEmail)

    $('.add-invitee-icon').on 'click',  ->
      self.acceptPanelistInputHelper(self.pitchLfaEmail)
  
  acceptPanelistInputHelper: (pitchLfaEmail) ->
    email_pattern = /^[a-z]{2,}\.[a-z]{2,}@andela\.com$/
    panelist_email = $.trim($('.invite-panelist2').val())

    return @flashErrorMessage("Email must be a valid Andela Email") unless panelist_email.match email_pattern
    return @flashErrorMessage("Email is already in the list") if @pitchLfaEmail.indexOf(panelist_email) != -1
    return @flashErrorMessage("Email is already in the list of panelists") if @allPitchLfaEmails.indexOf(panelist_email) != -1

    @pitchLfaEmail.unshift panelist_email if panelist_email != ''
    $('.invite-panelist2').val('')
    @displayPanelistEmail(@pitchLfaEmail)

  displayPanelistEmail: (pitchLfaEmail) ->
    self = @
    options = ''
    pitchLfaEmail.map (email) ->
      name = email.split(".")
      first = name[0].slice(0,1)
      second = name[1].slice(0,1)
      options += """
      <div class="panel-invitee-list-item">
        <div class="invitee-detail">
          <span class="panel-invitee-initials">#{first} #{second}</span>
          <span class="panel-invitee-email">#{email}</span>
        </div>
        <span class="panel-close-btn lfa-delete2"></span>
      </div>
      """
    $('.list-lfa-email').html(options)
    self.deletePanelistEmail(pitchLfaEmail)
    options = ''

  deletePanelistEmail: (pitchLfaEmail) ->
    self = @
    $(".lfa-delete2").click (e) ->
      index = $('.panel-invitee-list-item').index(e.target.closest('.panel-invitee-list-item'))
      e.target.closest('.panel-invitee-list-item').remove()
      deleted = pitchLfaEmail.splice(index, 1)
      self.allPitchLfaEmails = self.allPitchLfaEmails.filter((email) -> email != deleted[0])

  addPanel: () ->
    self = @
    $('.create-panel-btn').on 'click', (event) ->
      panel_name = $.trim($('.panel-name-input').val())
      selected_learners_length = self.selectedLearners.length
      selected_panelists_length = self.pitchLfaEmail.length

      return self.flashErrorMessage("Please enter a name for panel") unless panel_name
      return self.flashErrorMessage("Please select learners") unless selected_learners_length > 0
      return self.flashErrorMessage("Please enter a list of panelists") unless selected_panelists_length > 0
      return self.flashErrorMessage("A panel with similar name already exists") if self.panelNames.indexOf(panel_name) != -1

      self.panelNames.unshift panel_name if panel_name != ''
      new_selected_learners = self.allSelectedInPanel.concat self.selectedLearners
      self.allSelectedInPanel = new_selected_learners

      new_selected_lfa_emails = self.allPitchLfaEmails.concat self.pitchLfaEmail
      self.allPitchLfaEmails = new_selected_lfa_emails
      self.createPanels()
      if $('.create-panel-btn').text() == 'Update Panel'
        $('.create-panel-btn').html('Add Panel')



  selectLearnerForPanel: (target) ->
    self = @
    panel_learners_object = {}
    selected_panel_learner_name = target.find('input').data("learner_name")
    selected_panel_learner_id = target.find('input').val()
    name = selected_panel_learner_name.split(" ")
    panel_learners_object = {
      id: selected_panel_learner_id,
      name: selected_panel_learner_name
      first_name: name[0],
      last_name: name[1]
    }
    self.selectedLearners.unshift(panel_learners_object)
    self.displaySelectedLearner(self.selectedLearners)
    self.selectPanelLearners()

  displaySelectedLearner: (all_panel_learners) ->
    self = @
    learners = ''
    all_panel_learners.map (panel_learner) ->
      learners += """
        <li id = #{panel_learner.id}>
          #{panel_learner.name}
          <span data-target="#{panel_learner.id}" class="selected-learner-close">&times;</span>
        </li>
      """
    $(".selected-learners").html(learners)
    $('.selected-learners .selected-learner-close').on 'click', -> (
      self.removeLearner($(this))
    )
    learners = ""

  removeLearner: (target) ->
    self = @
    remove_learner = target.data('target')
    self.selectedLearners = self.selectedLearners.filter((learner) -> learner.id != remove_learner)
    target.remove()
    self.selectPanelLearners()
    self.displaySelectedLearner(self.selectedLearners)


  createPreviewPanelCard: (name, learners_no, panellists_no) ->
    self = @
    $('#no-panel-message').hide()
    new_name = name.split(' ').join('-')
    panel_card = """
      <div class="panel-card panel-card-#{new_name}">
        <div class="panel-body">
          <span class="preview-pane-panel-#{new_name} preview-pane-panel-close" ></span>
          <div class="title">#{name}</div>
          <div class="panelists">#{panellists_no} Panelist</div>
        </div>
        <div class="panel-card-footer">
          <div class="learners">#{learners_no} Learners</div>
        </div>
      </div>
    """
    $(".panels-container").append(panel_card)
    $(".preview-pane-panel-#{new_name}").on('click', -> 
      self.removePreviewPanelCard(name)
      $(".panel-card-#{new_name}").remove()
      self.selectPanelLearners()
    )

    $(".panel-card-#{new_name}").on('click', ->
      if $('.create-panel-btn').text() == 'Update Panel'
        self.flashErrorMessage("Save current changes before updating another panel")
      else
        $('.create-panel-btn').html('Update Panel')
        self.editPreviewPanelCard(name)
        $(".panel-card-#{new_name}").remove()
        self.selectPanelLearners()
    )
  removePreviewPanelCard: (name) -> 
    self = @
    checkPanelName = @panels.find((panel) -> panel.panel_name == name )
    filterLfaEmails = @allPitchLfaEmails.filter((lfaEmails) -> !checkPanelName.panellists.includes(lfaEmails))
    @allPitchLfaEmails = filterLfaEmails
    filterAllSelectedInPanel = @allSelectedInPanel.map((selected) -> selected.id).filter((panelLearner) -> !checkPanelName.panel_learners.includes(panelLearner))
    newSelectedInPanel = @allSelectedInPanel.filter((newInPanel) -> filterAllSelectedInPanel.includes(newInPanel.id))
    @allSelectedInPanel = newSelectedInPanel
    filterPanelNames = @panelNames.filter((clickedPanelName) -> !name.includes(clickedPanelName))
    @panelNames = filterPanelNames
    filterPanels = @panels.filter((selectedPanelName) -> !name.includes(selectedPanelName.panel_name))
    @panels = filterPanels
    if @panels.length == 0
      $('#no-panel-message').show()
      $('#submit-panel-btn').hide()

  editPreviewPanelCard: (name) ->
      self = @
      clickedPanel= @panels.find((panel) -> panel.panel_name == name )
      self.pitchLfaEmail = clickedPanel.panellists
      self.displayPanelistEmail(clickedPanel.panellists)
      filterAllSelectedInPanel = @allSelectedInPanel.map((selected) -> selected.id).filter((panelLearner) -> clickedPanel.panel_learners.includes(panelLearner))
      selectedLearnersInPanel = @allSelectedInPanel.filter((newInPanel) -> filterAllSelectedInPanel.includes(newInPanel.id))
      @selectedLearners = selectedLearnersInPanel
      @allSelectedInPanel = $(@allSelectedInPanel).not(@selectedLearners).get()
      @removePreviewPanelCard(name)
      @displaySelectedLearner(@selectedLearners)
      $('.invite-panelist').val(name)

  
  createPanels: () ->
    $('#submit-panel-btn').show()
    learners_selected = @selectedLearners.map ((learner)  -> learner.id)
    new_panel = {

        panel_name: $.trim($('.panel-name-input').val()),
        panellists: @pitchLfaEmail
        panel_learners: learners_selected
    }
    @panels.unshift new_panel
    @createPreviewPanelCard(new_panel.panel_name, new_panel.panel_learners.length, new_panel.panellists.length)
    @clearFields()
    @selectPanelLearners()

  handleSavePanels: () ->
    self = @
    $('#submit-panel-btn').click ->
      $('.saving-btn').show()
      $('#submit-panel-btn').hide()
      self.api.createPanel({panels: self.panels }, self.flashErrorMessage)
        .then((data) -> (
          if data.message
            self.flashSuccessMessage(data.message)
            window.location.href = "#{location.protocol}//#{location.host}/pitch/#{pageUrl[2]}/panels"
          else
            self.flashErrorMessage(data.error)
            $('.saving-btn').hide()
            $('#submit-panel-btn').show()
        ))

  toggleFilter: ->
    self = @
    $('#summary-name-filter').on 'click', () ->
      $('#filter-summary').toggle()

  closeFilterModal: ->
    self = @
    $('html').on 'click', (e) ->
      if (not $(e.target).closest('#filter','.filter-body').length)
        $('.filter-body').hide()

  showFilteredLearnerAverage: ->
    self = @
    no_data = """
              <h2 class='center-blank-state-text no-data-summary'>No data to show &#128577;</h2>
              """
    $('#filter-button').off('click').click ->
      name = $('#filter-name').val().toLowerCase()
      self.checkNameInput("#{name}")
      self.api.getPitchRatingSummary(self.summaryContentPerPage, self.summaryPagination.page, "#{name}")
      .then((data) -> (
        if data.paginated_data.length == 0
          $(".summary-table").hide()
          $(".btn-wrapper").hide()
          $("#no-data").append(no_data)
        else
          $(".no-data-summary").remove()
          $(".btn-wrapper").show()
          $(".summary-table").show()
          self.summaryContentCount = data.data_count
          self.summaryPaginatedData = data.paginated_data
          self.summaryPagination.initialize(
            self.summaryContentCount, self.api.getPitchRatingSummary,
            self.populatePitchLearnerAverage, self.summaryContentPerPage, {}, ".pagination-control.summary-page-pagination"
          )
          self.populatePitchLearnerAverage(data.paginated_data)
      ))

  checkNameInput: (name)->
    self = @
    if name.trim() == ''
      return @flashErrorMessage("Please enter a name")

  handleEditSubmit: ->
    self = @
    $('#submit-panel-btn').click ->
      $('.saving-btn').show()
      $('#submit-panel-btn').hide()
      learners = self.getLearners()
      panelists = self.getPanelists()
      data = {
      learners: learners,
      panelists: panelists
      }
      self.api.updatePanel(data, self.flashErrorMessage)
        .then((data) -> (
          if data.message
            self.flashSuccessMessage(data.message)
            window.location.href = "#{location.protocol}//#{location.host}/pitch/#{pageUrl[2]}/panels"
            $('.saving-btn').hide()
          else if data.error
            $('.saving-btn').hide()
            $('#submit-panel-btn').show()
          else
            $('.saving-btn').hide()
            $('#submit-panel-btn').show()
        ))

  clearFields: () ->
    @selectedLearners = []
    @pitchLfaEmail = []
    $('.list-lfa-email').html('')
    $(".selected-learners").html('')
    $('.panel-name-input').val('')

  getLearners: ->
    self = @
    allLearners = self.selectedLearners.map((learner) -> learner.id)
    existingLearners = self.panelLearners.map((learner) -> learner.bootcamper.camper_id)
    addedLearners = $(allLearners).not(existingLearners).get()
    removedLearner = $(existingLearners).not(allLearners).get()

    return self.flashErrorMessage("Please select learners") unless allLearners.length > 0

    learners = {
      addedLearners: addedLearners,
      removedLearners: removedLearner,
      allLearners: allLearners
    }

  getPanelists: ->
    self = @
    existingPans = self.existingPanelists.map((panelist) -> panelist.email)
    removedPans = $(existingPans).not(self.pitchLfaEmail).get()
    addedPans = $(self.pitchLfaEmail).not(existingPans).get()

    return self.flashErrorMessage("Please enter a list of panelists") unless self.pitchLfaEmail.length > 0

    panelists = {
      removedPanelists: removedPans,
      addedPanelists: addedPans
      allPanelists: self.pitchLfaEmail
    }

  handleBackButton: ->
    $(".tab-btn-back-icon").on 'click', () ->
      window.location.href = "/pitch/#{pageUrl[2]}/panels"
  
  fetchPitchLearnerAverage: =>
    self = @
    $("#summary-tab, #filter-reset-btn").off("click").click ->
      if pageUrl[1] == 'pitch' && pageUrl[3] == 'panels' && pageUrl.length == 4
        self.api.getPitchRatingSummary(self.summaryContentPerPage, self.summaryPagination.page)
        .then((data) -> (
            self.summaryContentCount = data.data_count
            self.summaryPaginatedData = data.paginated_data
            self.summaryPagination.initialize(
              self.summaryContentCount, self.api.getPitchRatingSummary,
              self.populatePitchLearnerAverage, self.summaryContentPerPage, {}, ".pagination-control.summary-page-pagination"
            )
            self.populatePitchLearnerAverage(data.paginated_data)
            $('#filter-name').val('')
            $(".no-data-summary").remove()
            $(".summary-table").show()
          )
        )
    $("#panel-tab").click(->
      self.getAllPanels()
    )


  populatePitchLearnerAverage: (learnersAverage) =>
    self = @
    $("#pitch-summary-data").html("")
    if learnersAverage.length
      learnersAverage.forEach((learner) ->
        self.populatePitchLearnerRow(learner)
      )

  populatePitchLearnerRow: (learnerAverage) =>
    self = @
    summary = """
    <tr class='pitch-summary' id="">
      <td class=''>
        <a href="ratings/#{learnerAverage[1].learners_panel_id}" class='one-learner-breakdown'>
          #{learnerAverage[1].first_name} #{learnerAverage[1].last_name}
        </a>
      </td>
      <td class='mdl-data-table__cell--non-numeric'>#{learnerAverage[0]}</td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage[1].avg_ui_ux).toFixed(1)}</td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage[1].avg_api_functionality).toFixed(1)}</td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage[1].avg_error_handling).toFixed(1)}</td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage[1].avg_project_understanding).toFixed(1)}</td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage[1].avg_presentational_skill).toFixed(1)}</td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage[1].cumulative_average).toFixed(1)}</td>
    </tr>

    """
    $("#pitch-summary-data").append(summary)
    
    
