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


