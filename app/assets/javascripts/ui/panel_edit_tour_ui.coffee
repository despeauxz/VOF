class Panel.PanelEditTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {} 

  initPanelEditTour: ->
    self = @
    $(".tour-trigger").off("click").click ->
      self.startPanelEditTour()

    @tourAPI.getUserTourStatus('panel_edit').then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        self.startPanelEditTour()
  
  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints()
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  startPanelEditTour: ->
    self = @
    @mainIntro.removeHints()
    @mainIntro.hideHints()
    @tourAPI.createTourEntry('panel_edit')
    steps = @tourContent.panelEditSteps

    if ($('.selected-learners').children().length == 0)
      steps = steps.filter (step) -> step.element != '.selected-learners'

    if ($('.invitee-list-items').children().length == 0)
      steps = steps.filter (step) -> step.element != '.invitee-list'

    @mainIntro.setOptions({
      steps
      hidePrev: true
      hideNext: true
      scrollToElement: true
      scrollPadding: -100000000
      showStepNumbers: false
      skipLabel: "Skip the Tour"
      hintButtonLabel: "Got it!"
    })

    @mainIntro.onchange ->
      if this._currentStep == 0
        $('.introjs-fullbutton').css({'background': '#4aa071', 'width': '100px'})
        $('.introjs-fullbutton').text('Get Started')
      else if this._currentStep != 0
        $('.introjs-nextbutton').css('background': '#3359db', 'width': '50px')
        $('.introjs-nextbutton').text('Next →')
      
      if this._currentStep == 4
        $('.invitee-list').css('background-color', 'white')

    @mainIntro.oncomplete ->
      self.takeThisTourAgainHint()

    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
