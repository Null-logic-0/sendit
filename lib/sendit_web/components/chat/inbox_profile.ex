defmodule SenditWeb.Chat.InboxProfile do
  use SenditWeb, :html

  def inbox_profile(assigns) do
    ~H"""
    <div class="fixed z-10 sm:w-xs w-full bottom-0 bg-base-100 border-t border-base-200  p-2 flex  items-center gap-2 shrink-0">
      <img src={@current_scope.user.avatar} class="rounded-full object-cover w-12 h-12" />

      <div class="flex-1">
        <p class="text-sm font-medium truncate">
          {@current_scope.user.full_name}
        </p>

        <p class="text-xs text-base-content/40 truncate">
          @{@current_scope.user.username}
        </p>
      </div>

      <div class="dropdown dropdown-top dropdown-end">
        <button
          tabindex="0"
          type="button"
          class="btn btn-ghost btn-sm btn-circle"
        >
          <.icon name="hero-ellipsis-horizontal" class="size-5" />
        </button>

        <ul
          tabindex="0"
          class="dropdown-content menu bg-base-100 rounded-2xl w-56 p-2 shadow-xl border border-base-200 mb-2"
        >
          <li>
            <.link navigate={~p"/users/settings"}>
              <.icon name="hero-cog-6-tooth" class="size-4" /> Settings
            </.link>
          </li>

          <div class="divider my-1"></div>

          <li>
            <.link
              href={~p"/users/log-out"}
              method="delete"
              class="text-error"
            >
              <.icon name="hero-arrow-left-on-rectangle" class="size-4" /> Log out
            </.link>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
