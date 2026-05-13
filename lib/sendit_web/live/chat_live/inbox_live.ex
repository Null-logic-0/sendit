defmodule SenditWeb.ChatLive.InboxLive do
  use SenditWeb, :live_view
  import SenditWeb.Chat.InboxSidebar
  alias Sendit.Accounts

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.inbox_sidebar current_scope={@current_scope} items={@users} />
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    users = Accounts.list_users()

    socket =
      socket
      |> assign(users: users)

    {:ok, socket}
  end
end
