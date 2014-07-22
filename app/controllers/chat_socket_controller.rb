class ChatSocketController < WebsocketRails::BaseController

  # The initialize_session method will be called the first time a controller is subscribed to an event in the event router.
  # Values added to the controller data store from inside the initialize_session method will be available throughout the course of the server lifetime.
  def initialize_session
    controller_store[:users_count] = 0
  end

  def new_message
    broadcast_message :new_message, {message: "#{message[:message]}", datetime: "#{message[:datetime]}", user_name: "#{message[:user_name]}"}
  end

  # Un usuario se ha conectado al chat
  # Action provided by websockets rails fired when user subscribe to channel
  def client_connected
    # incrementamos contadores
    if !controller_store[:users_count].blank?
      controller_store[:users_count] += 1
    else
      controller_store[:users_count] = 0
    end
    # Se notifica a todos los conectados por multidifusión
    logger.debug message.inspect
    broadcast_message :users_count_changed, {users_count: controller_store[:users_count]}
    # Se notifica al usuario que se acaba de conectar
    send_message :connection_success, {message: 'Conexión ok. Habla ahora o calla para siempre.'}
  end

  # Un usuario se ha desconectado del chat porque ha abandonado la página
  # Action provided by websockets rails fired when user unsubscribe to channel
  def client_disconnected
    if !controller_store[:users_count].blank?
      controller_store[:users_count] -= 1
    else
      controller_store[:users_count] = 0
    end
    # Se notifica al resto de usuarios conectados de que hay un usuario menos en el chat
    broadcast_message :users_count_changed, {users_count: controller_store[:users_count]}
  end
end
