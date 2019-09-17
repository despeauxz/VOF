class Panel.PanelSetupTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new Panel.PanelSetupTour.UI(@api)

   start: ->
    @ui.initPanelSetupTour()
