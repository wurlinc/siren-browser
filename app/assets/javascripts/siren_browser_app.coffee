class SirenBrowserApp
  constructor: ->
    @root_uri = null
    @current_uri = null
    console.log('started SirenBrowserApp')
    @update_current_uri()
    $(document).on('change', '#current_uri', @update_current_uri)
    $(document).on('click', '#go_to_root_uri', @go_to_root_uri)
    $(document).on('click', '#go_button', @go_button_click)

  current_uri_element: =>
    return $('#current_uri')

  update_current_uri: =>
    current_val = $('#current_uri').val()
    console.debug("setting current_uri to #{current_val}")
    @current_uri = URI(current_val)

  go_to_root_uri: =>
    root = URI('/').absoluteTo(@current_uri)
    console.debug("root uri = #{root.toString()}")
    @set_current_uri(root)

  set_current_uri:(uri) =>
    @current_uri_element().val(uri.toString())

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
    debugger
    console.log( "SUCCESS:", response )

  request_error: (error) =>
    console.log("ERROR: #{error}")

$(document).ready ->
  window.sirenBrowserApp = new SirenBrowserApp()

