class SirenBrowserApp
  constructor: ->
    @root_uri = null
    @current_uri = null
    console.log('started SirenBrowserApp')
    @update_current_uri()
    $(document).on('change', '#current_uri', @update_current_uri)
    $(document).on('click', '#go_to_root_uri', @go_to_root_uri)

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



$(document).ready ->
  window.sirenBrowserApp = new SirenBrowserApp()

