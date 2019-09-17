class Panel.PanelSetup.App
  constructor: ->
    @api = new Panel.API()
    @ui = new Panel.PanelSetup.UI(@api)

  start: =>
    @ui.initialize()

  pitchPanel: () =>
    @ui.pitchPanel()

  update: (panel_id) =>
    @ui.update(panel_id)
