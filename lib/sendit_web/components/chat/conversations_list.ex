defmodule SenditWeb.Chat.ConversationsList do
  use SenditWeb, :html
  import SenditWeb.UI.{AsyncList, EmptyState}

  def conversations_list(assigns) do
    ~H"""
    <.async_list assign={@conversations}>
      <:empty>
        <.empty_state
          icon="hero-chat-bubble-left-right"
          title="No conversations found"
          class="my-12"
          description="Search for a user to start chatting."
        >
          <:action>
            <button
              type="button"
              title="New conversation"
              onclick="conv_modal.showModal()"
              class="btn btn-primary btn-sm btn-rectangle"
            >
              Add Conversation
            </button>
          </:action>
        </.empty_state>
      </:empty>
      <:item :let={conversation}>
        <% {display_name, display_avatar} =
          if conversation.is_group do
            {conversation.title, nil}
          else
            other_user = Enum.find(conversation.users, &(&1.id != @current_scope.user.id))
            {other_user.full_name, other_user.avatar}
          end %>
        <% last_message = List.last(conversation.messages) %>
        <div
          id={"conversation-#{conversation.id}"}
          class="group flex items-center gap-3 px-4 py-3 hover:bg-base-200 w-full"
        >
          <.link
            navigate={~p"/chat/#{conversation.id}"}
            class="flex flex-1 items-center gap-3 min-w-0"
          >
            <%= if display_avatar do %>
              <img src={display_avatar} class="h-10 w-10 rounded-full object-cover shrink-0" />
            <% else %>
              <div class="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center shrink-0">
                <.icon name="hero-user-group" class="h-5 w-5 text-primary" />
              </div>
            <% end %>

            <div class="flex flex-col min-w-0 flex-1">
              <div class="flex items-center justify-between gap-1">
                <p class="truncate text-sm font-medium text-base-content">
                  {display_name}
                </p>
                <%= if last_message do %>
                  <span class="text-[10px] text-base-content/40 shrink-0">
                    {format_time(last_message.inserted_at)}
                  </span>
                <% end %>
              </div>

              <div class="flex items-center justify-between gap-1">
                <%= if last_message do %>
                  <p class="truncate text-xs text-base-content/50">
                    <%= if conversation.is_group do %>
                      <span class="font-medium">{last_message.user.username}: </span>
                    <% end %>
                    {last_message.body}
                  </p>
                <% end %>

                <%= if (conversation.messages_count || 0) > 0 do %>
                  <span class="badge badge-primary badge-xs shrink-0">
                    {min(conversation.messages_count, 99)}
                  </span>
                <% end %>
              </div>
            </div>
          </.link>

          <%= if conversation.creator_id == @current_scope.user.id do %>
            <div class="dropdown dropdown-end relative">
              <button
                tabindex="0"
                type="button"
                class="btn btn-ghost btn-sm btn-circle opacity-100 md:opacity-0 md:group-hover:opacity-100"
              >
                <.icon name="hero-ellipsis-horizontal" class="h-5 w-5" />
              </button>
              <ul
                tabindex="0"
                class="dropdown-content menu z-10 w-52 rounded-box bg-base-100 p-2 shadow"
              >
                <li>
                  <.link
                    phx-click={
                      JS.push("delete_conversation", value: %{id: conversation.id})
                      |> JS.hide(to: "#conversation-#{conversation.id}")
                    }
                    data-confirm="Are you sure?"
                    class="text-error flex items-center gap-2"
                  >
                    <.icon name="hero-trash" class="h-4 w-4" /> Delete
                  </.link>
                </li>
              </ul>
            </div>
          <% end %>
        </div>
      </:item>
    </.async_list>
    """
  end

  defp format_time(nil), do: ""

  defp format_time(dt) do
    now = DateTime.utc_now()
    diff_days = Date.diff(DateTime.to_date(now), DateTime.to_date(dt))

    cond do
      diff_days == 0 -> Calendar.strftime(dt, "%H:%M")
      diff_days == 1 -> "Yesterday"
      diff_days < 7 -> Calendar.strftime(dt, "%A")
      true -> Calendar.strftime(dt, "%d/%m/%y")
    end
  end
end
