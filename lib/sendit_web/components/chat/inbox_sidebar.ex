defmodule SenditWeb.Chat.InboxSidebar do
  use SenditWeb, :html

  import SenditWeb.UI.{
    AppLogo,
    ThemeToggle,
    Modal,
    Search
  }

  import SenditWeb.Chat.{
    InboxProfile,
    UsersList,
    ConversationsList
  }

  def inbox_sidebar(assigns) do
    ~H"""
    <aside class={[
      "flex flex-col bg-base-100 border-r border-base-200",
      "absolute inset-0 z-20 md:relative md:inset-auto md:z-auto",
      "w-full md:w-80 md:shrink-0",
      if(@mobile_show_chat, do: "flex", else: "hidden md:flex")
    ]}>
      <div class="navbar border-b border-base-200 min-h-0 px-4 py-3 gap-2 shrink-0">
        <div class="navbar-start gap-2">
          <.app_logo link={~p"/chat"} />
        </div>
        <div class="navbar-end gap-1">
          <.theme_toggle />
        </div>
      </div>

      <div class="flex items-center gap-3  p-3 border-b border-base-300">
        <.search
          placeholder="Search Conversations..."
          change="search-conversations"
          id="search-conversations"
          form={@conversations_form}
        />
        <button
          type="button"
          class="btn btn-ghost btn-sm btn-circle mb-2"
          title="New conversation"
          onclick="conv_modal.showModal()"
        >
          <.icon name="hero-plus" class="size-5" />
        </button>
      </div>

      <.modal id="conv_modal" title="New conversation">
        <.search
          placeholder="Search Users..."
          form={@users_form}
          change="search-users"
          id="search-users"
          class="px-4"
        />
        <div class="max-h-[60vh] overflow-y-auto">
          <.users_list users={@users} />
        </div>
        <div class="px-4 py-2 border-t border-base-200 text-xs text-base-content/50">
          Select a user to start chatting
        </div>
      </.modal>

      <div class="overflow-y-auto pb-16">
        <.conversations_list conversations={@conversations} current_scope={@current_scope} />
      </div>

      <.inbox_profile current_scope={@current_scope} />
    </aside>
    """
  end
end
