# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.websocketsExample = {
  domain : "",
  dispatcher : null,
  user_name : ""
}

# inicializa el dominio (podemos estar en producción o en desarrollo)
window.websocketsExample.init = (domain) ->
  window.websocketsExample.domain = domain

# Recibe el nombre de usuario, el primer mensaje e inicializa la conexión.
window.websocketsExample.start = (user_name) ->
  window.websocketsExample.user_name = user_name
  if((window.websocketsExample.user_name == undefined) or window.websocketsExample.user_name == "")
    alert "Elige un nombre de usuario primero"
  else
    window.websocketsExample.dispatcher = new WebSocketRails("#{window.websocketsExample.domain}/websocket")
    window.websocketsExample.bind_events()

# Define los eventos que se dispararán durante la ejecución.
window.websocketsExample.bind_events = () ->
  window.websocketsExample.dispatcher.on_open = (data) ->
    console.log "Connection has been established: ", data
    return

  window.websocketsExample.dispatcher.bind('new_message', window.websocketsExample.new_message_received)
  window.websocketsExample.dispatcher.bind('connection_success', window.websocketsExample.connection_success)
  window.websocketsExample.dispatcher.bind('users_count_changed', window.websocketsExample.users_count_changed)

# Callback cuando se ha recibido un mensaje nuevo
window.websocketsExample.new_message_received = (response) ->
  console.log response
  alert response.message

# Callback cuando un usuario se ha conectado
window.websocketsExample.connection_success = (response) ->
  console.log response
  alert response.message

# Callback cuando un usuario se ha desconectado
window.websocketsExample.users_count_changed = (response) ->
  console.log response
  alert response.message

# Envía un mensaje de chat al servidor
window.websocketsExample.send_message = (message) ->
  object_to_send = {user_name: window.websocketsExample.user_name, message: message}
  window.websocketsExample.dispatcher.trigger('new_message', object_to_send)
