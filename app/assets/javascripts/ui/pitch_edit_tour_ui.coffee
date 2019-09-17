class Pitch.PitchEditTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @stepTwo = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {}
    @hintsOnPage = 0
    @pitchEditTourModal = new Modal.App('#pitch-edit-tour-modal', 672, 672, 598, 598)


  initPitchEditTour: ->
    if pageUrl[3] == 'edit'
      $('.tour-trigger').off('click').click =>
        @startPitchEditTour()

      @tourAPI.getUserTourStatus('pitch_edit').then (tourData) =>
        @tourContent = tourData.content
        unless tourData.has_toured
          @pitchEditTourModal.open()

  registerEventListeners: ->
    self = @
    $('#pitch-edit-tour-button').click ->
      self.pitchEditTourModal.close()
      self.startPitchEditTour()

      $('#skip-tour-btn').click ->
      self.pitchEditTourModal.close()
      self.tourAPI.createTourEntry('pitch_edit')

  startPitchEditTour: ->
    self = @
    @mainIntro.removeHints()
    @mainIntro.hideHints()
    @tourAPI.createTourEntry('pitch_edit')

    @mainIntro.setOptions({
      steps: @tourContent.pitchEditTourSteps
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
        $('#update-btn').css('display', 'block')
        $('#next-btn').css('display', 'none')
      else
        $('#tab-btn-back-text').text('Update Pitch')
        $('.pitch-tab.pitch-tab-1').css('display', 'block')
        $('.pitch-tab.pitch-tab-4').css('display', 'none')
        $('#update-btn').css('display', 'none')
        $('#next-btn').css('display', 'block')

    @mainIntro.onafterchange ->
      if this._currentStep == 7
        setTimeout(self.reduceHelperLayer, 10)

    @mainIntro.oncomplete ->
      $('#tab-btn-back-text').text('Update Pitch')
      $('.pitch-tab.pitch-tab-1').css('display', 'block')
      $('.pitch-tab.pitch-tab-4').css('display', 'none')
      $('#update-btn').css('display', 'none')
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


  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints()
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })

    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()

    $('.introjs-hint').css("z-index", 1000)
