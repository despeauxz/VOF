class Support.SupportSetup.App
  constructor: ->
    @api = new Support.API()
    @ui = new Support.SupportSetup.UI(@api)

  start: =>
    @ui.initialize()
