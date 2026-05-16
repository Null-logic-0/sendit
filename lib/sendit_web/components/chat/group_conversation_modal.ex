defmodule SenditWeb.Chat.GroupConversationModal do
  use SenditWeb, :html
  import SenditWeb.UI.{Modal, Search, AsyncList}

  def group_conversation_modal(assigns) do
    ~H"""
    <.modal id="group_modal" title="New group conversation">
      <div class="flex flex-col gap-3 px-4 pt-2">
        <input
          type="text"
          name="group_title"
          placeholder="Group name..."
          phx-blur="set_group_title"
          class="input input-bordered w-full"
        />
      </div>

      <.search
        placeholder="Search Users..."
        form={@form}
        change="search-users"
        id="search-users-group"
        class="px-4 pt-2"
      />

      <div class="max-h-[35vh] overflow-y-auto">
        <.async_list
          assign={@users}
          empty_icon="hero-user-group"
          empty_title="No users found"
          empty_description="Search for users to add."
        >
          <:item :let={user}>
            <div
              phx-click="toggle_group_user"
              phx-value-user_id={user.id}
              class={[
                "flex items-center gap-3 px-4 py-3 bg-primary/10 cursor-pointer hover:bg-base-200 w-full text-left",
                if(to_string(user.id) in @selected_user_ids, do: "bg-primary/10")
              ]}
            >
              <img src={user.avatar} class="rounded-full object-cover w-10 h-10" />
              <div class="flex flex-col flex-1">
                <p class="text-sm font-medium truncate">{user.full_name}</p>
                <p class="text-xs font-medium">@{user.username}</p>
              </div>
              <%= if to_string(user.id) in @selected_user_ids do %>
                <.icon name="hero-check-circle" class="size-5 text-primary shrink-0" />
              <% end %>
            </div>
          </:item>
        </.async_list>
      </div>

      <div class="px-4 py-3 border-t border-base-200 flex items-center justify-between gap-2">
        <p class="text-xs text-base-content/50">
          {length(@selected_user_ids)} user(s) selected
        </p>
        <button
          type="button"
          phx-click="create_group_conversation"
          disabled={length(@selected_user_ids) < 2}
          class="btn btn-primary btn-sm"
        >
          Create Group
        </button>
      </div>
    </.modal>
    """
  end
end
