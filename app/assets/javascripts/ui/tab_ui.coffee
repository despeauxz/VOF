class Tab.UI
  constructor: (
    supportCardClass = 'support-card',
    tabHeaderClass = 'tab-header',
    tabContentClass = 'tab-content'
  ) ->

    @supportCard = document.getElementsByClassName(supportCardClass)
    @tabHeader = document.getElementsByClassName(tabHeaderClass)
    @tabContent = document.getElementsByClassName(tabContentClass)

  initializeTab: =>
    self = @
    $(@supportCard).click ->
      tabId = $(this).attr('data-tab')
      $(self.supportCard).removeClass('current support-card-active')
      $(self.tabHeader).removeClass('active-header')
      $(self.tabContent).removeClass('current')
      $(this).addClass('current support-card-active')
      $(this).find('h6').addClass('active-header')
      $('#' + tabId).addClass('current')

    @viewAllUsers()
    @backToCreateNewRole()
    @setPermisions()
    @backToNewRole()
    @viewPermission()

  viewAllUsers: ->
    self = @
    $('.view-all-users').off('click').click ->
      $('.roles-and-permissions-page').hide()
      $('.all-users').show()

  backToCreateNewRole: ->
    self = @
    $('.all-users-caption').off('click').click ->
      $('.all-users').hide()
      $('.roles-and-permissions-page').show()

  setPermisions: ->
    self = @
    $('.set-permissions').off('click').click ->
      $(self.tabContent).removeClass('current')
      $('#tab-6').addClass('current')

  viewPermission: ->
    self = @
    $('.view-permissions').click ->
      $(self.tabContent).removeClass('current')
      $('#tab-6').addClass('current')

  backToNewRole: ->
    self = @
    $('.permissions-for-new').off('click').click ->
      $('#tab-6').removeClass('current')
      $('#tab-5').addClass('current')

