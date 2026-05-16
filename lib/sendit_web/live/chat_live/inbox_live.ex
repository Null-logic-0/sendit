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
        mobile_show_chat={@mobile_show_chat}
        selected_user_ids={@selected_user_ids}
      />

      <%= if @live_action == :show do %>
        <% {display_name, display_subtitle} =
          if @conversation.is_group do
            {@conversation.title, "#{length(@conversation.users)} members"}
          else
            u = Enum.find(@conversation.users, &(&1.id != @current_scope.user.id))
            {u.full_name, "@#{u.username}"}
          end %>

        <div class={[
          "sticky w-full max-h-[80px] top-0 z-10
           flex items-center pr-2 py-3
           border-b border-base-200 bg-base-100",
          if(@mobile_show_chat, do: "hidden md:flex", else: "flex")
        ]}>
          <div class="flex flex-1 items-center gap-2">
            <.link navigate={~p"/chat"} class="btn btn-ghost btn-sm btn-circle shrink-0">
              <.icon name="hero-chevron-left" class="size-6" />
            </.link>

            <%= if @conversation.is_group do %>
              <div class="w-14 h-14 rounded-full bg-primary/10 flex items-center justify-center shrink-0">
                <.icon name="hero-user-group" class="size-7 text-primary" />
              </div>
            <% else %>
              <% u = Enum.find(@conversation.users, &(&1.id != @current_scope.user.id)) %>
              <img src={u.avatar} class="w-14 h-14 rounded-full object-cover shrink-0" />
            <% end %>

            <div>
              <p class="text-lg font-semibold truncate">{display_name}</p>
              <p class="text-xs text-base-content/50 truncate">{display_subtitle}</p>
            </div>
          </div>

          <div class="drawer drawer-end flex justify-end">
            <input id="my-drawer-5" type="checkbox" class="drawer-toggle" />
            <div class="drawer-content">
              <label for="my-drawer-5" class="drawer-button btn btn-ghost btn-sm btn-circle shrink-0">
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
                    <p class="text-xl font-semibold">{display_name}</p>
                    <p class="text-sm text-base-content/50">{display_subtitle}</p>
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
    |> assign(:mobile_show_chat, not Map.has_key?(params, "id"))
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
    |> assign(:selected_user_ids, [])
    |> assign(:group_title, "")
  end

  def handle_event("toggle_group_user", %{"user_id" => user_id}, socket) do
    selected = socket.assigns.selected_user_ids

    updated =
      if user_id in selected,
        do: List.delete(selected, user_id),
        else: [user_id | selected]

    {:noreply, assign(socket, :selected_user_ids, updated)}
  end

  def handle_event("set_group_title", %{"value" => title}, socket) do
    {:noreply, assign(socket, :group_title, title)}
  end

  def handle_event("create_group_conversation", _params, socket) do
    %{selected_user_ids: user_ids, group_title: title, current_scope: scope} = socket.assigns

    user_ids_ints = Enum.map(user_ids, &String.to_integer/1)

    case Chat.create_group_conversation(scope, user_ids_ints, title) do
      {:ok, conversation} ->
        {:noreply,
         socket
         |> assign(:selected_user_ids, [])
         |> assign(:group_title, "")
         |> push_navigate(to: ~p"/chat/#{conversation.id}")}

      {:error, changeset} ->
        {:noreply,
         put_flash(socket, :error, "Could not create group: #{error_summary(changeset)}")}
    end
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

  defp error_summary(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    |> Enum.map(fn {field, msgs} -> "#{field}: #{Enum.join(msgs, ", ")}" end)
    |> Enum.join("; ")
  end
end
