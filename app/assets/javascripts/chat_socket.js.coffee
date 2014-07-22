# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.websocketsExample = {
  domain : "",
  dispatcher : null,
  user_name : "",
  connected : false
}
############## INICIALIZADORES ####################
# inicializa el dominio (podemos estar en producción o en desarrollo)
window.websocketsExample.init = (domain) ->
  window.websocketsExample.domain = domain

# Recibe el nombre de usuario, el primer mensaje e inicializa la conexión.
window.websocketsExample.start = () ->
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

############## CALLBACKS ####################
# Callback cuando se ha recibido un mensaje nuevo
window.websocketsExample.new_message_received = (response) ->
  $('#chat_messages_index').append(
    "<li class='left clearfix message' data-time=#{response.datetime}>
      <div class='chat-body clearfix'>
        <div class='header'>
          <strong class='primary-font'>#{response.user_name}</strong>
          <small class='pull-right text-muted'>
            <span class='glyphicon glyphicon-time'></span>
            <span class='datetime-ago'>#{window.websocketsExample.timeSince(response.datetime)}</span>
          </small>
        </div>
        <p>
         #{response.message}
        </p>
      </div>
      <hr>
    </li>"
  )

# Callback cuando me he conectado
window.websocketsExample.connection_success = (response) ->
  $('#chat_messages_index').append(
    "<li class='left clearfix'>
      <div class='chat-body clearfix text-center text-muted'>
        <small>
        <p>
         #{response.message}
        </p>
        <small>
      </div>
      <hr>
    </li>"
  )
  window.websocketsExample.connected = true
  # deshabilito el botón de conectar
  $('#btn_connect_chat').html('¡Conectado!')
  $('#btn_connect_chat').addClass('disabled')

  # Habilito el chat
  $('#btn_send_chat').removeClass('disabled').html('Enviar')
  $('#message_input').removeAttr('disabled')

  window.websocketsExample.calc_timeSince()

# Callback cuando un usuario se ha desconectado
window.websocketsExample.users_count_changed = (response) ->
  $('#connected_users_count').html(response.users_count)

############## ENVÍO DE MENSAJES ####################
# Envía un mensaje de chat al servidor
window.websocketsExample.send_message = (message) ->
  if((message != undefined) and (message != ''))
    object_to_send = {user_name: window.websocketsExample.user_name, message: message, datetime: new Date()}
    window.websocketsExample.dispatcher.trigger('new_message', object_to_send)
    $('#message_input').val('')

############## VALIDADORES ####################
# validador nombre
window.websocketsExample.enable_to_send = () ->
  if($('#name_input').val().length > 2)
    # Guardo el nombre de usuario
    window.websocketsExample.user_name = $('#name_input').val()
    # tengo nombre pero...
    if !window.websocketsExample.connected
      # ...no estoy conectado todavía. Habilito el botón para iniciar la conexión
      $('#btn_connect_chat').removeClass('disabled')
    else
      # ...ya estoy conectado, dejo inservible el botón
      $('#btn_connect_chat').addClass('disabled')
      $('#btn_connect_chat').html('¡Conectado!')
      # Habilito el chat
      $('#btn_send_chat').removeClass('disabled').html('Enviar')
      $('#message_input').removeAttr('disabled')
  else
    # no tengo nombre pero...
    if !window.websocketsExample.connected
      # ...no estoy conectado. Inhabilito el botón de conectar
      $('#btn_connect_chat').addClass('disabled')
    else
      # ...estoy conectado. Me he cambiado el nombre a uno vacío
      $('#btn_connect_chat').addClass('disabled')
      $('#btn_connect_chat').html('¡Conectado!')
      # inhabilito el chat
      $('#btn_send_chat').addClass('disabled').html('Nombre corto')
      $('#message_input').attr('disabled', 'disabled')


###################### TIME AGO FUNCTION ##################

# A partir de una fecha, devuelve una expresión del tipo "Hace 1 segundo"
window.websocketsExample.timeSince = (date) ->
    if (typeof date != 'object')
      date = new Date(date)

    seconds = Math.floor((new Date() - date) / 1000);

    interval = Math.floor(seconds / 31536000)

    if (interval >= 1)
        return "#{interval} años"
    
    interval = Math.floor(seconds / 2592000)
    if (interval >= 1)
        return "#{interval} meses"
    
    interval = Math.floor(seconds / 86400)
    if (interval >= 1)
        return "#{interval} días"
    
    interval = Math.floor(seconds / 3600);
    if (interval >= 1)
        return "#{interval} horas"
    
    interval = Math.floor(seconds / 60)
    if (interval >= 1)
        return "#{interval} minutos"
    
    return  "#{Math.floor(seconds)} segundos"

# Busca las fechas de los comentarios de los chats y las cambia a expresiones del tipo "hace 1 segundo"
window.websocketsExample.calc_timeSince = () ->
  setInterval (->
    $("li.left.clearfix.message").each (index) ->
      $(this).find('.datetime-ago').html(window.websocketsExample.timeSince($(this).attr('data-time')))
      return
    return
  ), 10000
  