defmodule SenditWeb.Chat.ChatInfoDrawer do
  use SenditWeb, :html

  def chat_info_drawer(assigns) do
    ~H"""
    <div class="drawer drawer-end flex justify-end">
      <input id="my-drawer-5" type="checkbox" class="drawer-toggle" />
      <div class="drawer-content">
        <label
          for="my-drawer-5"
          class="drawer-button btn btn-ghost btn-sm btn-circle shrink-0"
        >
          <.icon name="hero-information-circle" class="size-6 text-info" />
        </label>
      </div>
      <div class="drawer-side">
        <label for="my-drawer-5" aria-label="close sidebar" class="drawer-overlay"></label>
        <div class="flex flex-col items-center bg-base-200 min-h-full w-80 pt-12 pb-6 px-4 gap-4">
          <%= if @conversation.is_group do %>
            <div class="w-24 h-24 rounded-full bg-primary/10 flex items-center justify-center shrink-0">
              <.icon name="hero-user-group" class="size-12 text-primary" />
            </div>
            <div class="text-center">
              <p class="text-xl font-semibold">{@display_name}</p>
              <p class="text-sm text-base-content/50">{@display_subtitle}</p>
            </div>
            <div class="w-full border-t border-base-300 py-4 flex flex-col gap-1 overflow-y-scroll h-[75vh]">
              <p class="text-xs font-semibold text-base-content/50 uppercase px-1 mb-2">
                Members
              </p>
              <%= for user <- @conversation.users do %>
                <div class="flex items-center gap-3 px-2 py-2 rounded-lg hover:bg-base-300 ">
                  <img src={user.avatar} class="w-9 h-9 rounded-full object-cover shrink-0" />
                  <div class="flex flex-col min-w-0">
                    <p class="text-sm font-medium truncate">{user.full_name}</p>
                    <p class="text-xs text-base-content/50 truncate">@{user.username}</p>
                  </div>
                  <%= if user.id == @current_scope.user.id do %>
                    <span class="badge badge-primary badge-xs ml-auto">you</span>
                  <% end %>
                </div>
              <% end %>
            </div>
          <% else %>
            <% u = Enum.find(@conversation.users, &(&1.id != @current_scope.user.id)) %>
            <img src={u.avatar} class="w-24 h-24 rounded-full object-cover shrink-0" />
            <div class="text-center">
              <p class="text-xl font-semibold">{u.full_name}</p>
              <p class="text-lg text-base-content/50">@{u.username}</p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
