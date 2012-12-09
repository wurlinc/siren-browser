class SirenBrowserApp
  constructor: ->
    console.info('started SirenBrowserApp')
    # models
    @current_uri = new CurrentUri(uri: '')
    @current_response = new SirenResponse()

    # views
    @go_button_view = new GoButtonView(el: '#go_button', model: @current_uri, app:this)
    @current_uri_view = new CurrentUriView(el: '#current_uri', model: @current_uri, go_button_view: @go_button_view)
    @siren_response_view = new SirenResponseLinksView(el:'#links', model:@current_response)

    # trigger some initialization

    # load all the mustache templates
    $.Mustache.addFromDom()
    # make sure the current uri is synced with the DOM
    @current_uri_view.update_current_uri()
    # trigger rendering the empty response views
    @current_response.set('data', {})

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


class SirenResponseLinksView extends Backbone.View
  initialize:(options) ->
    @model.bind('change', @render, this)

  render: ->
    console.debug('rendering SirenResponseLinksView')
    @$el.find('#links_body').mustache('links_template', @model.get('data'), { method: 'html' })


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
    console.debug('button clicked')
    @app.request_current_uri()

############################
# Start the app on page load
$ ->
  window.app = new SirenBrowserApp()

