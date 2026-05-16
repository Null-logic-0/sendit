defmodule SenditWeb.Chat.Presence do
  use Phoenix.Presence,
    otp_app: :sendit,
    pubsub_server: Sendit.PubSub
end
