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
    @message_view = new MessageView(el:'#messages', app:this)
    # trigger some initialization

    # load partials
    @register_partial(partial) for partial in $('script.partial')

    # make sure the current uri is synced with the DOM
    @current_uri_view.set_current_uri()
    # trigger rendering the empty response views
    @current_response.set('data', {})

  set_current_uri:(uri) ->
    console.debug("SirenBrowserApp#set_current_uri(#{uri})")
    @current_uri.set('uri', uri)

  request_current_uri: ->
    @get()

  clear_messages: ->
    @message_view.clear()

  submit_action:(action_name, data) ->
    console.debug("submit_action(#{action_name}, #{data})")
    action = @current_response.find_action(action_name)
    $.ajax(action.href, {
      type: action.method
      success: @request_success
      error: @request_error
      complete: @request_complete
    })

  get: ->
    url = @current_uri.get('uri')
    console.info("GET #{url}")
    $.ajax(url, {
      type: 'GET',
      data: 'json',
      success: @request_success,
      error: @request_error
    })

  # if data is a string, parse
  # because in some browsers jquery
  # is returning a string
  parse_json:(data) ->
    if (typeof data) == "string"
      data = $.parseJSON(data)

    return data

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
    data = @parse_json(data)

    @current_response.set('data', data)

  request_error:(jqXHR, textStatus, errorThrown) =>
    console.warn("SirenBrowserApp#request_error(%o, #{textStatus}, #{errorThrown})", jqXHR)
    data = @parse_json(jqXHR.responseText)
    if(data)
      @current_response.set('data', data)
      message = @current_response.properties()['message']
      rel = @current_response.find_link_by_rel('related')
      @set_current_uri(rel.href) if rel

    else
      message = "An error occurred making the request. message: #{errorThrown}, status:#{textStatus}"

    @message_view.error({message:message})

  request_complete:(jqXHR, textStatus) =>
    console.debug("SirenBrowserApp#request_complete(#{jqXHR}, #{textStatus})")
    $(document).trigger('siren:request_complete')

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

  find_link_by_rel:(rel) ->
    link = _.find(@links(), (link) ->
      console.debug('find_link_by_rel ', link.rel)
      link.rel == rel
    )

    return link

  class: ->
    return @get('data')['class']

  properties: ->
    return @get('data')['properties']

  links: ->
    return @get('data')['links']

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
    "siren:request_complete" : "close"

  initialize:(options) ->
    @model.bind('change', @render, this)
    @app = options.app
    @template = Handlebars.compile($('#action_submission_template').html())
    @action_name = options.action_name
    # since this view created on-demand, need to clean-up
    @$el.bind('reveal:close', @close)

  _el_body: ->
    return @$el.find('#action_submission_body')

  close: (event) =>
    @undelegateEvents()
    @model.unbind('change', @render, this)
    @$el.unbind('reveal:close', 'close')

  render: ->
    console.debug('rendering ActionSubmissionView')
    action = @model.find_action(@action_name)
    results = @template(action)
    @_el_body().html(results)

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

class MessageView extends Backbone.View
  initialize:(options) ->
    @app = options.app
    @error_template = Handlebars.compile($('#error_message').html())

  error:(data) ->
    results = @error_template(data)
    @$el.html(results)

  clear: ->
    @$el.html("")

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
    @app.clear_messages()
    @app.request_current_uri()


############################
# Start the app on page load
$ ->
  window.app = new SirenBrowserApp()

