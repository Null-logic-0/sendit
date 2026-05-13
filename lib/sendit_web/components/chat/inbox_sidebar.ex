defmodule SenditWeb.Chat.InboxSidebar do
  use SenditWeb, :html

  import SenditWeb.UI.{
    AppLogo,
    ThemeToggle,
    Modal
  }

  import SenditWeb.Chat.{
    InboxProfile,
    ConversationList
  }

  def inbox_sidebar(assigns) do
    ~H"""
    <aside class={
      [
        "flex flex-col bg-base-100 border-r border-base-200",
        "absolute inset-0 z-20 md:relative md:inset-auto md:z-auto",
        "w-full md:w-80 md:shrink-0"
        # if(@mobile_show_chat, do: "hidden md:flex", else: "flex")
      ]
    }>
      <div class="navbar border-b border-base-200 min-h-0 px-4 py-3 gap-2 shrink-0">
        <div class="navbar-start gap-2">
          <.app_logo link={~p"/chat"} />
        </div>
        <div class="navbar-end gap-1">
          <.theme_toggle />
        </div>
      </div>

      <div class="flex items-center gap-2 p-3 border-b border-base-200 shrink-0">
        <div class="relative flex-1 flex items-center gap-2 ">
          <.icon name="hero-magnifying-glass" class="size-4 opacity-50 absolute z-10 left-1" />
          <input
            type="search"
            placeholder="Search conversations…"
            class="input pl-6 pr-1 py-4 rounded-lg input-sm bg-base-200 border-none focus-within:outline-none text-sm"
          />
        </div>
        <button
          type="button"
          class="btn btn-ghost btn-sm btn-circle shrink-0"
          title="New conversation"
          onclick="conv_modal.showModal()"
        >
          <.icon name="hero-plus" class="size-5" />
        </button>
      </div>

      <.modal id="conv_modal" title="New conversation">
        <div class="max-h-[60vh] overflow-y-auto">
          <.conversation_list items={@items} />
        </div>
        <div class="px-4 py-2 border-t border-base-200 text-xs text-base-content/50">
          Select a user to start chatting
        </div>
      </.modal>

      <.conversation_list items={@items} />

      <.inbox_profile current_scope={@current_scope} />
    </aside>
    """
  end
end
