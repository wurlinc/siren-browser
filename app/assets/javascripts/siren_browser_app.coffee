class SirenBrowserApp
  constructor: ->
    console.log('started SirenBrowserApp')
    @root_uri = null
    @current_uri = null
    @api_link_handler = new ApiLinkHandler(this)
    @current_uri_input_handler = new CurrentUriInputHandler(this)
    @set_current_uri(@current_uri_input_handler.get_val())

    $(document).on('click', '#go_to_root_uri', @go_to_root_uri)
    $(document).on('click', '#go_button', @go_button_click)

  set_current_uri:(url) =>
    console.debug("setting current_uri to #{url}")
    @current_uri = URI(url)
    @current_uri_input_handler.set_val(url)

  go_to_root_uri: =>
    root = URI('/').absoluteTo(@current_uri)
    console.debug("root uri = #{root.toString()}")
    @set_current_uri(root)

  go_button_click: =>
    @request_current_uri()

  request_current_uri: =>
    $.ajax(
      type: "GET",
      url: @current_uri.toString()
      contentType: "application/json"
      success: @request_success
      error: @request_error
    )

  request_success: (response) =>
    console.log( "SUCCESS:", response )

  request_error: (error) =>
    console.log("ERROR: #{error}")

class ApiLinkHandler
  constructor:(@app) ->
    $(document).on('click', '.api_link', (event) =>
      url = $(event.target).attr('href')
      event.preventDefault()
      @app.set_current_uri(url)
      @app.request_current_uri()
    )

class CurrentUriInputHandler
  constructor:(@app) ->
    @current_uri_element = $('#current_uri')
    @current_uri_element.on('change', (event) =>
      event.preventDefault()
      url = @current_uri_element.val()
      @app.set_current_uri(url)
    )

  set_val:(url) =>
    @current_uri_element.val(url)

  get_val: =>
    @current_uri_element.val()






$(document).ready ->
  window.sirenBrowserApp = new SirenBrowserApp()

