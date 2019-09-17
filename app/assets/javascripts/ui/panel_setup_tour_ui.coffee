class Panel.PanelSetupTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {}

  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.2")

  registerEventListeners: ->
    self = @
    $('.tour-trigger').off("click").click ->
      self.startPanelSetupTour()

  initPanelSetupTour: ->
    self = @
    self.registerEventListeners()

    @tourAPI.getUserTourStatus('panel_setup').then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        self.startPanelSetupTour()

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints()
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  startPanelSetupTour: () ->
    self =  @
    @mainIntro.removeHints()
    @mainIntro.hideHints()
    @tourAPI.createTourEntry('panel_create')
    
    if $('#submit-panel-btn').css('display') == 'none'
      steps = @tourContent.panelCreateSteps.filter (step) ->
        step.element != '#submit-panel-btn'
    else
      steps = @tourContent.panelCreateSteps
      
    @mainIntro.setOptions({
      steps
      scrollToElement: true
      scrollPadding: -100000000
      showStepNumbers: false
      hintButtonLabel: "Got it!"
      skipLabel: "Skip the Tour"
      hidePrev: true
      hideNext: true
    })
    @mainIntro.onchange ->
      if this._currentStep == 0
        $('.introjs-fullbutton').css({'background': '#4aa071', 'width': '100px'})
        $('.introjs-fullbutton').text('Get Started')
      else if this._currentStep != 0
        $('.introjs-nextbutton').css('background': '#3359db', 'width': '50px')
        $('.introjs-nextbutton').text('Next →')

    @mainIntro.oncomplete ->
      this.addHints()
      this.showHints()
      self.takeThisTourAgainHint()
    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
