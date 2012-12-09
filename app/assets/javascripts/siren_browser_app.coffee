class SirenBrowserApp
  constructor: ->
    console.info('started SirenBrowserApp')
    @current_uri = new CurrentUri(uri: '')
    @current_uri_view = new CurrentUriView(el: $('#current_uri'), model: @current_uri)

class CurrentUri extends Backbone.Model
  defaults:
    uri: null

class CurrentUriView extends Backbone.View
  initialize: ->
    @model.bind('change', @render, this)

  events:
    "change" : "update_current_uri"

  render: ->
    console.debug('rendering CurrentUriView')
    @$el.val(@model.get('uri').toString())
    return this

  update_current_uri: (event) ->
    console.debug("update_current_uri: #{@$el.val()}")
    @model.set('uri', @$el.val())


$ ->
  window.app = new SirenBrowserApp()

