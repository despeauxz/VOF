class Panel.PanelsPageTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @takeTourAgainHint = introJs()
    @showMoreOptionsTour = introJs()
    @summaryTabTour = introJs()
    @hintsOnPage = 0
    @tourContent = {}

  initPanelsPageTour: ->
    self = @
    self.registerEventListeners()
    @tourAPI.getUserTourStatus('panels_page').then (data) ->
      self.tourContent = data.content
      unless data.has_toured
        self.startPanelsPageTour()
  
  registerEventListeners: ->
    self = @
    $('.tour-trigger').off('click').click ->
      self.startPanelsPageTour()

  startPanelsPageTour: ->
    if !$('#panel-section').hasClass('is-active')
      $('#summary-section').removeClass('is-active')
      $('#panel-section').addClass('is-active')

    self = @
    @mainIntro.removeHints()
    @mainIntro.hideHints()
    @tourAPI.createTourEntry('panel_setup')
  
    if $('.panel-card').length
      steps = @tourContent.panelSetupSteps.filter (step) ->
        step.element != '.new-panel-btn'
    else if $('.new-panel-btn').length
      steps = @tourContent.panelSetupSteps.filter (step) ->
        step.element != '.panel-card' &&
        step.element != '#new-panel-btn' &&
        step.element != '.dashboard-main-section'

      panelHints = @tourContent.pitchSetupHints.filter (hint) ->
        hint.element != '.more-icon' 
    else
      steps = @tourContent.panelSetupSteps

    if !$('#new-panel-btn').length
      steps = steps.filter (step) ->
        step.element != '#new-panel-btn'

    hints = panelHints || @tourContent.pitchSetupHints
    @mainIntro.setOptions({
      steps
      hints
      scrollToElement: true
      scrollPadding: -100000000
      showStepNumbers: false
      hintButtonLabel: "Click"
      skipLabel: "Skip the Tour"
      hidePrev: true
      hideNext: true
    })
    
    @mainIntro.onchange ->
      if this._currentStep == 0
        $('.introjs-fullbutton').css({ 'background': '#4aa071', 'width': '100px' })
        $('.introjs-fullbutton').text('Get Started')
      else if this._currentStep != 0
        $('.introjs-nextbutton').css({ 'background': '#3359db', 'width': '50px' })
        $('.introjs-nextbutton').text('Next →')

    @mainIntro.oncomplete ->
      this.addHints()
      this.showHints()
      if $(".introjs-hint").length > 1
        self.hintsOnPage = self.tourContent.pitchSetupHints.length
      else
        self.takeThisTourAgainHint()

    @mainIntro.onhintclose (hintId) ->
      self.hintsOnPage -= 1
      switch hintId
        when 0
          if hints.length > 1 then self.initShowMoreOptions() 
          else self.initSummaryTabTour()

        when 1
          self.initSummaryTabTour()
    
    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
    @mainIntro.hideHints()

  takeThisTourAgainHint: ->
    @takeTourAgainHint.hideHints()
    @takeTourAgainHint.removeHints()
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  initShowMoreOptions: ->
    self = @
    @showMoreOptionsTour.setOptions({
      steps: @tourContent.moreOptionsSteps
      showStepNumbers: false
      disableInteraction: true
      skipLabel: "Skip the Tour"
    })

    @showMoreOptionsTour.start()
 
  initSummaryTabTour: ->
    self = @
    $('#summary-tab-card').click()
    @summaryTabTour.hideHints()
    @summaryTabTour.removeHints()

    if $('.no-data').length
      steps = @tourContent.summaryTabSteps.filter (step) ->
        step.element != '.pitch-summary-table-head' &&
        step.element != '.pitch-summary-table-body' && 
        step.element != '#summary-name-filter'
    else
      steps = @tourContent.summaryTabSteps.filter (step) ->
        step.element != '.summary-grid'

    @summaryTabTour.setOptions({
      steps
      scrollToElement: true
      scrollPadding: -100000000
      showStepNumbers: false
      disableInteraction: true
      skipLabel: "Skip the Tour"
      hidePrev: true
      hideNext: true      
    })

    @summaryTabTour.onchange () ->
      if this._introItems.length == 2 
        if this._currentStep == 1
          $('.summary-grid').css('background-color', 'white') 

    @summaryTabTour.onexit ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        self.takeThisTourAgainHint()
      )

    @summaryTabTour.start()
    @summaryTabTour.goToStepNumber(1)

