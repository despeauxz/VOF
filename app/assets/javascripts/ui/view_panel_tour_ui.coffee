class Panel.ViewPanelTour.UI
 constructor: (tourAPI) -> 
   @tourAPI= tourAPI
   @mainIntro = introJs()
   @panelistsIntro = introJs()
   @takeTourAgainHint= introJs()
   @tourContent = {}
   @hintsOnPage = 0
   @role = ''

  initViewPanelTour: ->
    self = @
    $(".tour-trigger").off("click").click ->
      $('#panellists-tab, #panellists-panel').removeClass("is-active")
      $('#learners-tab, #learners-panel').addClass("is-active")
      $('#learners-tab').click
      self.startViewPanelTour()

    @tourAPI.getUserTourStatus('view_panel').then (tourData) ->
      self.tourContent = tourData.content
      self.role = tourData.role
      unless tourData.has_toured
        self.startViewPanelTour()


  initPanelistsIntro: -> 
     self = @
     @panelistsIntro.removeHints()
     @panelistsIntro.hideHints()
     @panelistsIntro.setOptions({
      steps: @tourContent.panelistsSteps,
      hidePrev: true,
      hideNext: true
      showStepNumbers: false
      skipLabel: "Skip the Tour"
     })

     @panelistsIntro.oncomplete ->
        self.takeThisTourAgainHint()

     @panelistsIntro.start()


  takeThisTourAgainHint: -> 
      @takeTourAgainHint.removeHints()
      @takeTourAgainHint.setOptions({
        hints: @tourContent.takeThisTourAgainHint,
        hintButtonLabel: "Got it"
      })
      @takeTourAgainHint.addHints()
      @takeTourAgainHint.showHints()
      $('.introjs-hint').css("z-index", 1000)


  startViewPanelTour: -> 
      self = @
      @mainIntro.removeHints()
      @mainIntro.hideHints()
      @tourAPI.createTourEntry('view_panel')
      @mainIntro.setOptions({
        steps: @tourContent.panelViewSteps,
        hints: @tourContent.panelPageHints,
        hidePrev: true
        hideNext: true
        scrollToElement: true
        scrollPadding: -100000000
        showStepNumbers: false
        skipLabel: "Skip the Tour"
        hintButtonLabel: "Click"
      })

      @mainIntro.onchange ->
        if this._currentStep == 0
         $('.introjs-fullbutton').css({'background': '#4aa071', 'width': '100px'})
         $('.introjs-fullbutton').text('Get Started')
        else if this._currentStep != 0
         $('.introjs-nextbutton').css('background': '#3359db', 'width': '50px')
         $('.introjs-nextbutton').text('Next →')

      @mainIntro.oncomplete ->
        if self.role == 'LFA'
           self.takeThisTourAgainHint()
        else if self.role != 'LFA'
          this.addHints()
          this.showHints()
       
      @mainIntro.onhintclose ->
        $('#panellists-tab, #panellists-panel').addClass("is-active")
        $('#learners-tab, #learners-panel').removeClass("is-active")
        $('#panellists-tab').click 
        self.initPanelistsIntro()

      @mainIntro.exit()
      @mainIntro.start()
      @mainIntro.goToStepNumber(1)
