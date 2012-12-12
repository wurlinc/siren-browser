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

    # trigger some initialization

    # load all the mustache templates
    #$.Mustache.addFromDom()
    # make sure the current uri is synced with the DOM
    @current_uri_view.update_current_uri()
    # trigger rendering the empty response views
    @current_response.set('data', {})

  set_current_uri:(uri) ->
    @current_uri.set('uri', uri)

  request_current_uri: ->
    @get()

  get: ->
    url = @current_uri.get('uri')
    console.info("GET #{url}")
    $.ajax(url, {
      success: @request_success,
      error: @request_error
    })

  request_success:(data, textStatus, jqXHR) =>
    @current_response.set('data', $.parseJSON(data))

  request_error:(jqXHR, textStatus, errorThrown) =>
    console.warn("request error: #{textStatus} #{errorThrown}")



class SirenResponse extends Backbone.Model
  defaults:
    data: {empty:true}

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


class CurrentUriView extends Backbone.View
  initialize:(options) ->
    @model.bind('change', @render, this)
    @go_button_view = options.go_button_view

  events:
    "change" : "update_current_uri"
    "keypress" : "go_on_enter"

  render: ->
    console.debug('rendering CurrentUriView')
    @$el.val(@model.get('uri'))
    return this

  update_current_uri: (event) ->
    console.debug("update_current_uri: #{@$el.val()}")
    @model.set('uri', @$el.val())

  go_on_enter:(event) ->
    if (event.keyCode == 13)
      $(@go_button_view.el).click()


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

