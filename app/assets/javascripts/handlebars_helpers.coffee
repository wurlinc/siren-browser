#// HELPER: #key_value
#//
#// Usage: {{#key_value obj}} Key: {{key}} // Value: {{value}} {{/key_value}}
#//
#// Iterate over an object, setting 'key' and 'value' for each property in
#// the object.

Handlebars.registerHelper("key_value", (obj, options) ->
  buffer = ""
  for key,value of obj
    buffer += options.fn({key: key, value: value})

  return buffer
)

Handlebars.registerHelper("action_link_classes", (obj, options) ->
  classes = "tiny button"
  if this.method and this.method.toUpperCase() == "DELETE"
    classes += " alert"

  return classes
)

