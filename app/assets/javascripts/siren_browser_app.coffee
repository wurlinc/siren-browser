class SirenBrowserApp
  constructor: ->
    console.info('started SirenBrowserApp')
    # models
    @current_uri = new CurrentUri(uri: '')
    @current_response = new SirenResponse()

    # views
    @go_button_view = new GoButtonView(el: '#go_button', model: @current_uri, app:this)
    @current_uri_view = new CurrentUriView(el: '#current_uri', model: @current_uri, go_button_view: @go_button_view)
    @siren_links_view = new SirenResponseLinksView(el:'#links', app:this, model:@current_response)
    @siren_properties_view = new SirenResponsePropertiesView(el:'#properties', app:this, model:@current_response)
    @siren_entities_view = new SirenResponseEntitiesView(el:'#entities', app:this, model:@current_response)
    @siren_actions_view = new SirenResponseActionsView(
      el:'#actions'
      app:this
      model:@current_response
    )
    # trigger some initialization

    # load partials
    @register_partial(partial) for partial in $('script.partial')

    # make sure the current uri is synced with the DOM
    @current_uri_view.set_current_uri()
    # trigger rendering the empty response views
    @current_response.set('data', {})

  set_current_uri:(uri) ->
    @current_uri.set('uri', uri)

  request_current_uri: ->
    @get()

  submit_action:(action_name, data) ->
    console.debug("submit_action(#{action_name}, #{data})")
    debugger
    action = @current_response.find_action(action_name)
    $.ajax(action.href, {
      type: action.method
      success: @request_success
      error: @request_error
    })

  get: ->
    url = @current_uri.get('uri')
    console.info("GET #{url}")
    $.ajax(url, {
      success: @request_success,
      error: @request_error
    })


  prompt_action_submission:(action_name) ->
    console.debug("prompt for action: #{action_name}")
    action_submission_view = new ActionSubmissionView(
      el: '#action_modal'
      app: this
      model: @current_response
      action_name: action_name
    )

    action_submission_view.reveal()

  request_success:(data, textStatus, jqXHR) =>
    @current_response.set('data', $.parseJSON(data))

  request_error:(jqXHR, textStatus, errorThrown) =>
    console.warn("request error: #{textStatus} #{errorThrown}")

  # partial is a selector or jquery object for the script template
  # The script's id attribute will be used as the partial name
  register_partial:(partial) ->
    Handlebars.registerPartial($(partial).attr('id'), $(partial).html())

class SirenResponse extends Backbone.Model
  defaults:
    data: {empty:true}

  find_action:(action_name) ->
    data = @get('data')
    action = _.find(data.actions, (action) ->
      action.name == action_name
    )
    return action

class CurrentUri extends Backbone.Model
  defaults:
    uri: null

class SirenResponsePropertiesView extends Backbone.View
  initialize:(options) ->
    @model.bind('change', @render, this)
    @app = options.app
    @template = Handlebars.compile($('#properties_template').html())

  render: ->
    console.debug('rendering SirenResponsePropertiesView')
    results = @template(@model.get('data'))
    @$el.find('#properties_body').html(results)

class SirenResponseEntitiesView extends Backbone.View
  initialize:(options) ->
    @model.bind('change', @render, this)
    @app = options.app
    @template = Handlebars.compile($('#entities_template').html())

  events:
    "click .api_link" : "update_current_uri_and_request"

  render: ->
    console.debug('rendering SirenResponseEntitiesView')
    results = @template(@model.get('data'))
    @$el.find('#entities_body').html(results)

  update_current_uri_and_request: (event) ->
    event.preventDefault()
    url = $(event.target).attr('href')
    @app.set_current_uri(url)
    @app.request_current_uri()

class SirenResponseActionsView extends Backbone.View
  initialize:(options) ->
    @model.bind('change', @render, this)
    @app = options.app
    @template = Handlebars.compile($('#actions_template').html())

  events:
    "click .action_link" : "action_click"

  render: ->
    console.debug('rendering SirenResponseActionsView')
    results = @template(@model.get('data'))
    @$el.find('#actions_body').html(results)

  action_click: (event) ->
    event.preventDefault()
    action_name = $(event.target).data('name')
    @app.prompt_action_submission(action_name)

class SirenResponseLinksView extends Backbone.View
  initialize:(options) ->
    @model.bind('change', @render, this)
    @app = options.app
    @template = Handlebars.compile($('#links_template').html())

  events:
    "click .api_link" : "update_current_uri_and_request"

  render: ->
    console.debug('rendering SirenResponseLinksView')
    results = @template(@model.get('data'))
    @$el.find('#links_body').html(results)

  update_current_uri_and_request: (event) ->
    event.preventDefault()
    url = $(event.target).attr('href')
    @app.set_current_uri(url)
    @app.request_current_uri()

class ActionSubmissionView extends Backbone.View
  events:
    "submit .action_form" : "handle_action_form_submit"

  initialize:(options) ->
    @model.bind('change', @render, this)
    @app = options.app
    @template = Handlebars.compile($('#action_submission_template').html())
    @action_name = options.action_name
    # since this view created on-demand, need to clean-up
    @$el.bind('reveal:close', @close)

  close: (event) =>
    @model.unbind('change')
    @$el.unbind('reveal:close')

  render: ->
    console.debug('rendering ActionSubmissionView')
    action = @model.find_action(@action_name)
    results = @template(action)
    @$el.find('#action_submission_body').html(results)

  reveal: ->
    @render()
    @$el.reveal()

  handle_action_form_submit: (event) =>
    event.preventDefault()
    target = $(event.target)
    action_name = target.data('name')
    data = target.find('input').serializeArray()
    @app.submit_action(action_name, data)
    @$el.trigger('reveal:close')



class CurrentUriView extends Backbone.View
  initialize:(options) ->
    @model.bind('change', @render, this)
    @go_button_view = options.go_button_view

  events:
    "change" : "current_uri_changed"
    "keypress" : "go_on_enter"

  render: ->
    console.debug('rendering CurrentUriView')
    @$el.val(@model.get('uri'))
    return this

  current_uri_changed: (event) ->
    @set_current_uri()

  go_on_enter:(event) ->
    if (event.keyCode == 13)
      @set_current_uri()
      $(@go_button_view.el).click()

  get_current_uri: ->
    @$el.val()

  set_current_uri: ->
    @model.set('uri', @get_current_uri())

# el: go button element
# model: current_uri model
# app: the application instance
class GoButtonView extends Backbone.View
  initialize:(options) ->
    @app = options.app

  events:
    "click" : "click"

  click:(event) ->
    @app.request_current_uri()


############################
# Start the app on page load
$ ->
  window.app = new SirenBrowserApp()

