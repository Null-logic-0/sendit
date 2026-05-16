defmodule SenditWeb.Chat.ConversationModal do
  use SenditWeb, :html
  import SenditWeb.UI.{Modal, Search}
  import SenditWeb.Chat.UsersList

  def conversation_modal(assigns) do
    ~H"""
    <.modal id="conv_modal" title="New conversation">
      <div class="flex items-center gap-3 px-4">
        <.search
          placeholder="Search Users..."
          form={@form}
          change="search-users"
          id="search-users"
        />
      </div>
      <div class="max-h-[45vh] overflow-y-auto">
        <.users_list users={@users} />
      </div>
      <div class="px-4 py-2 border-t border-base-200 text-xs text-base-content/50">
        Select a user to start chatting
      </div>
    </.modal>
    """
  end
end
