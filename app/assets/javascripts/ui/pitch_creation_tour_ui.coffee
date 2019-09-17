class Pitch.PitchCreationTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @stepTwo = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {}
    @hintsOnPage = 0
    @pitchCreationTourModal = new Modal.App('#pitch-creation-tour-modal', 672, 672, 598, 598)

  initPitchCreationTour: ->
    if pageUrl[1] == 'pitch' and pageUrl[2] == 'setup'
      @registerEventListeners()

      $('.tour-trigger').off('click').click =>
        @startPitchCreationTour()

      @tourAPI.getUserTourStatus('pitch_creation').then (tourData) =>
        @tourContent = tourData.content
        unless tourData.has_toured
          @pitchCreationTourModal.open()

  registerEventListeners: ->
    self = @
    $('#pitch-creation-tour-button').click ->
      self.pitchCreationTourModal.close()
      self.startPitchCreationTour()

     $('#skip-tour-btn').click ->
      self.pitchCreationTourModal.close()
      self.tourAPI.createTourEntry('pitch_creation')

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints()
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  startPitchCreationTour: ->
    self = @
    @mainIntro.removeHints()
    @mainIntro.hideHints()
    @tourAPI.createTourEntry('pitch_creation')

    @mainIntro.setOptions({
      steps: @tourContent.pitchCreationTourSteps
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
      if this._currentStep >= 4
        $('#tab-btn-back-text').text('Schedule Demo Day')
        $('.pitch-tab.pitch-tab-1').css('display', 'none')
        $('.pitch-tab.pitch-tab-4').css('display', 'block')
        $('#submit-btn').css('display', 'block')
        $('#next-btn').css('display', 'none')
      else
        $('#tab-btn-back-text').text('Create a New Pitch')
        $('.pitch-tab.pitch-tab-1').css('display', 'block')
        $('.pitch-tab.pitch-tab-4').css('display', 'none')
        $('#submit-btn').css('display', 'none')
        $('#next-btn').css('display', 'block')

    @mainIntro.onafterchange ->
      if this._currentStep == 7
        setTimeout(self.reduceHelperLayer, 10)

    @mainIntro.oncomplete ->
      $('#tab-btn-back-text').text('Create a New Pitch')
      $('.pitch-tab.pitch-tab-1').css('display', 'block')
      $('.pitch-tab.pitch-tab-4').css('display', 'none')
      $('#submit-btn').css('display', 'none')
      $('#next-btn').css('display', 'block')
      self.takeThisTourAgainHint()

    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
    @mainIntro.hideHints()


  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.2")

  reduceIntroZIndex: ->
    $(".introjs-helperLayer").css("z-index", 99)
    $(".introjs-overlay").css("z-index", 100)
