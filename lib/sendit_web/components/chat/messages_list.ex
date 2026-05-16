defmodule SenditWeb.Chat.MessagesList do
  use SenditWeb, :html
  import SenditWeb.UI.AsyncList
  import SenditWeb.Chat.MessageItem

  def messages_list(assigns) do
    assigns = assign(assigns, :last_message_id, last_message_id(assigns.messages))

    ~H"""
    <div
      id="messages-container"
      phx-hook="ScrollToBottom"
      class="flex-1 overflow-y-auto px-4 py-4 flex flex-col gap-2"
    >
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
    </div>
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
