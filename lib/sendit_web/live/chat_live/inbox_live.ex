defmodule SenditWeb.ChatLive.InboxLive do
  use SenditWeb, :live_view
  import SenditWeb.Chat.InboxSidebar
  import SenditWeb.UI.EmptyState
  alias Sendit.Chat
  alias Sendit.Accounts

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.inbox_sidebar
        current_scope={@current_scope}
        users={@users}
        conversations={@conversations}
        conversations_form={@conversations_form}
        users_form={@users_form}
      />

      <%= if @live_action == :show do %>
        <% other_user =
          Enum.find(@conversation.users, &(&1.id != @current_scope.user.id)) %>
        <div class={
          [
            "
          sticky w-full max-h-[80px] top-0 z-10
          flex items-center  pr-2 py-3
          border-b border-base-200 bg-base-100"
            # if(@mobile_show_chat, do: "flex", else: "hidden md:flex")
          ]
        }>
          <div class="flex flex-1  items-center gap-2">
            <.link navigate={~p"/chat"} class="btn btn-ghost btn-sm btn-circle  shrink-0">
              <.icon name="hero-chevron-left" class="size-6" />
            </.link>
            <img src={other_user.avatar} class="w-14 h-14 rounded-full object-cover shrink-0" />
            <div>
              <p class="text-lg font-semibold truncate">{other_user.full_name}</p>
              <p class="text-xs text-base-content/50 truncate">@{other_user.username}</p>
            </div>
          </div>

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
              <div class="flex flex-col items-center  bg-base-200 min-h-full w-80 pt-20 py-6 px-4">
                <img src={other_user.avatar} class="w-24 h-24 rounded-full object-cover shrink-0" />
                <div>
                  <p class="text-xl text-center font-semibold truncate">{other_user.full_name}</p>
                  <p class="text-lg text-center text-base-content/50 truncate">
                    @{other_user.username}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% else %>
        <.empty_state
          icon="hero-chat-bubble-left-right"
          title="Select a conversation"
          class="flex justify-center w-full items-center"
          description="Choose a conversation from the sidebar to start chatting."
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
      <% end %>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id} = params, _uri, socket) do
    current_user = socket.assigns.current_scope

    case Chat.get_conversation!(current_user, id) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Conversation not found")
         |> push_navigate(to: ~p"/chat")}

      conversation ->
        {:noreply,
         socket
         |> base_assigns(params)
         |> assign(:conversation, conversation)}
    end
  end

  def handle_params(params, _uri, socket) do
    {:noreply, base_assigns(socket, params)}
  end

  defp base_assigns(socket, params) do
    current_user = socket.assigns.current_scope
    q_users = Map.get(params, "q_users", "")
    q_conversations = Map.get(params, "q_conversations", "")

    socket
    |> assign(page_title: "#{current_user.user.username}'s inbox")
    |> assign(:searching_users?, q_users != "")
    |> assign(:searching_conversations?, q_conversations != "")
    |> assign(:users_form, to_form(%{"q" => q_users}))
    |> assign(:conversations_form, to_form(%{"q" => q_conversations}))
    |> assign_async(:users, fn ->
      {:ok, %{users: Chat.list_users(%{"q" => q_users})}}
    end)
    |> assign_async(:conversations, fn ->
      {:ok, %{conversations: Chat.list_conversations(current_user, %{"q" => q_conversations})}}
    end)
  end

  def handle_event("search-users", %{"q" => q}, socket) do
    params = if q == "", do: %{}, else: %{"q_users" => q}
    {:noreply, push_patch(socket, to: ~p"/chat?#{params}", replace: true)}
  end

  def handle_event("search-conversations", %{"q" => q}, socket) do
    params = if q == "", do: %{}, else: %{"q_conversations" => q}
    {:noreply, push_patch(socket, to: ~p"/chat?#{params}", replace: true)}
  end

  def handle_event("start_conversation", %{"user_id" => user_id}, socket) do
    other_user = Accounts.get_user!(user_id)

    case Chat.get_or_create_conversation(socket.assigns.current_scope, other_user) do
      {:ok, conversation} ->
        {:noreply, push_navigate(socket, to: ~p"/chat/#{conversation.id}")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not start conversation")}
    end
  end

  def handle_event("delete_conversation", %{"id" => id}, socket) do
    case Chat.delete_conversation(socket.assigns.current_scope, id) do
      {:ok, _conversation} ->
        {:noreply, push_navigate(socket, to: ~p"/chat")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not delete conversation")}
    end
  end
end
