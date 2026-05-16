defmodule SenditWeb.Chat.ConversationsList do
  use SenditWeb, :html

  import SenditWeb.UI.{
    AsyncList,
    EmptyState
  }

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
        <% other_user =
          Enum.find(conversation.users, &(&1.id != @current_scope.user.id)) %>

        <div
          id={"conversation-#{conversation.id}"}
          class="group flex items-center gap-3 px-4 py-3 hover:bg-base-200 w-full"
        >
          <.link
            navigate={~p"/chat/#{conversation.id}"}
            class="flex flex-1 items-center gap-3 min-w-0"
          >
            <img
              src={other_user.avatar}
              class="h-10 w-10 rounded-full object-cover"
            />

            <div class="flex flex-col min-w-0">
              <p class="truncate text-sm font-medium text-base-content">
                {other_user.full_name}
              </p>
            </div>
          </.link>

          <div class="dropdown dropdown-end  relative">
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
        </div>
      </:item>
    </.async_list>
    """
  end
end
