defmodule SenditWeb.Chat.MessagesList do
  use SenditWeb, :html
  import SenditWeb.UI.AsyncList
  import SenditWeb.Chat.MessageItem

  def messages_list(assigns) do
    assigns = assign(assigns, :last_message_id, last_message_id(assigns.messages))

    ~H"""
    <.async_list
      assign={@messages}
      empty_icon="hero-chat-bubble-left-ellipsis"
      empty_title="No messages yet"
      empty_description="Say hello!"
    >
      <:item :let={message}>
        <.message_item
          message={message}
          current_scope={@current_scope}
          editing_message_id={@editing_message_id}
          read_timestamps={@read_timestamps}
          is_last={message.id == @last_message_id}
        />
      </:item>
    </.async_list>

    <%= for u <- @typing_users do %>
      <div class="chat chat-start">
        <div class="chat-image avatar">
          <div class="w-10 rounded-full">
            <img src={u.avatar} />
          </div>
        </div>
        <div class="chat-header mb-0.5">
          <span class="text-xs opacity-50">{u.full_name}</span>
        </div>
        <div class="chat-bubble py-3 px-4">
          <span class="loading loading-dots loading-sm"></span>
        </div>
      </div>
    <% end %>
    """
  end

  defp last_message_id(%Phoenix.LiveView.AsyncResult{result: messages}) when is_list(messages) do
    case List.last(messages) do
      nil -> nil
      msg -> msg.id
    end
  end

  defp last_message_id(_), do: nil
end
