defmodule SenditWeb.Chat.UsersList do
  use SenditWeb, :html

  import SenditWeb.UI.{AsyncList, Avatar}

  def users_list(assigns) do
    ~H"""
    <.async_list
      assign={@users}
      empty_icon="hero-user-group"
      empty_title="No users found"
      empty_description="Start by inviting your first team member."
    >
      <:item :let={user}>
        <% online? = user.id in @online_user_ids %>
        <div
          phx-click="start_conversation"
          phx-value-user_id={user.id}
          class="flex items-center gap-3 px-4 py-3 cursor-pointer hover:bg-base-200 w-full text-left"
        >
          <.avatar
            src={user.avatar}
            size="sm"
            online?={online?}
          />
          <div class="flex flex-col">
            <p class="text-sm font-medium truncate">
              {user.full_name}
            </p>
            <p class="text-xs font-medium ">
              @{user.username}
            </p>
          </div>
        </div>
      </:item>
    </.async_list>
    """
  end
end
