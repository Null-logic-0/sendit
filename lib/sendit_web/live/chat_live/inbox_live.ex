defmodule SenditWeb.ChatLive.InboxLive do
  use SenditWeb, :live_view

  import SenditWeb.Chat.{
    InboxSidebar,
    ChatHeader,
    MessagesList
  }

  import SenditWeb.UI.EmptyState

  alias Sendit.Chat
  alias Sendit.Accounts
  alias Phoenix.LiveView.AsyncResult

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
          "flex flex-col w-full",
          "flex-1 min-w-0",
          if(@mobile_show_chat, do: "hidden md:flex", else: "flex")
        ]}>
          <.chat_header
            current_scope={@current_scope}
            conversation={@conversation}
            display_name={display_name}
            display_subtitle={display_subtitle}
          />
          <div
            id="messages-container"
            phx-hook="ScrollToBottom"
            class="flex-1 overflow-y-auto px-4 py-4 flex flex-col gap-2"
          >
            <.messages_list
              messages={@messages}
              current_scope={@current_scope}
              editing_message_id={@editing_message_id}
              read_timestamps={@read_timestamps}
            />
          </div>
          <div class="border-t w-full bottom-0 bg-base-100 border-base-200 px-2 pb-3 pt-2 shrink-0">
            <%= if @editing_message_id do %>
              <div class="flex items-center gap-2 px-2 pb-1 text-xs text-base-content/50">
                <.icon name="hero-pencil" class="size-3" />
                <span>Editing message</span>
                <button
                  type="button"
                  phx-click="cancel_edit"
                  class="ml-auto text-base-content/50 hover:text-base-content"
                >
                  Cancel
                </button>
              </div>
            <% end %>
            <.form
              for={@message_form}
              phx-submit={if @editing_message_id, do: "update_message", else: "send_message"}
            >
              <div class="flex items-center gap-2 w-full">
                <textarea
                  name="body"
                  rows="1"
                  phx-hook="AutoGrow"
                  id="message-input"
                  placeholder={"Message #{display_name}…"}
                  class="input w-full resize-none bg-base-200 border-none h-auto pt-2 pb-4 px-3 rounded-2xl focus-within:outline-none"
                >{@draft_text}</textarea>

                <.button
                  type="submit"
                  class="btn btn-circle btn-primary mb-1"
                  title="Send"
                >
                  <.icon name="hero-paper-airplane" class="size-5" />
                </.button>
              </div>
            </.form>
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
    if connected?(socket) do
      Chat.subscribe_conversation(socket.assigns.current_scope)
    end

    {:ok, assign(socket, :read_timestamps, %{})}
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
        if connected?(socket) do
          Chat.subscribe_messages(conversation.id)
          Chat.mark_as_read(current_user, conversation.id)
        end

        {:noreply,
         socket
         |> base_assigns(params)
         |> update(:conversations, fn async ->
           %{
             async
             | result:
                 Enum.map(async.result || [], fn c ->
                   if c.id == conversation.id, do: %{c | messages_count: 0}, else: c
                 end)
           }
         end)
         |> assign(:conversation, conversation)
         |> assign(:editing_message_id, nil)
         |> assign(:draft_text, "")
         |> assign(:read_timestamps, Chat.get_read_timestamps(conversation.id))
         |> assign_async(:messages, fn ->
           {:ok, %{messages: Chat.list_messages(conversation.id)}}
         end)}
    end
  end

  def handle_params(params, _uri, socket) do
    {:noreply, base_assigns(socket, params)}
  end

  # ── PubSub handlers ──────────────────────────────────────────────

  def handle_info({:created, %Chat.Message{} = message}, socket) do
    viewing_this_conversation? =
      socket.assigns.live_action == :show &&
        Map.get(socket.assigns, :conversation) != nil &&
        socket.assigns.conversation.id == message.conversation_id

    if viewing_this_conversation? do
      Chat.mark_as_read(socket.assigns.current_scope, message.conversation_id)
    end

    {:noreply,
     update(socket, :messages, fn async ->
       %{async | result: (async.result || []) ++ [message]}
     end)}
  end

  def handle_info({:updated, %Chat.Message{} = message}, socket) do
    {:noreply,
     update(socket, :messages, fn async ->
       %{
         async
         | result:
             Enum.map(async.result || [], fn m ->
               if m.id == message.id, do: message, else: m
             end)
       }
     end)}
  end

  def handle_info({:deleted, %Chat.Message{} = message}, socket) do
    {:noreply,
     update(socket, :messages, fn async ->
       %{async | result: Enum.reject(async.result || [], &(&1.id == message.id))}
     end)}
  end

  def handle_info({:created, conversation}, socket) when is_struct(conversation) do
    {:noreply,
     update(socket, :conversations, fn async ->
       existing = async.result || []

       unless Enum.any?(existing, &(&1.id == conversation.id)) do
         %{async | result: [conversation | existing]}
       else
         async
       end
     end)}
  end

  def handle_info({:updated, conversation}, socket) when is_struct(conversation) do
    socket =
      if socket.assigns.live_action == :show &&
           Map.get(socket.assigns, :conversation) != nil &&
           socket.assigns.conversation.id == conversation.id do
        assign(socket, :read_timestamps, Chat.get_read_timestamps(conversation.id))
      else
        socket
      end

    {:noreply,
     update(socket, :conversations, fn async ->
       updated =
         (async.result || [])
         |> Enum.map(fn c -> if c.id == conversation.id, do: conversation, else: c end)
         |> Enum.sort_by(& &1.last_message_at, fn
           nil, nil -> true
           nil, _ -> false
           _, nil -> true
           a, b -> DateTime.compare(a, b) != :lt
         end)

       %{async | result: updated}
     end)}
  end

  def handle_info({:deleted, conversation}, socket) when is_struct(conversation) do
    socket =
      update(socket, :conversations, fn async ->
        %{async | result: Enum.reject(async.result || [], &(&1.id == conversation.id))}
      end)

    socket =
      if Map.get(socket.assigns, :conversation) != nil &&
           socket.assigns.conversation.id == conversation.id do
        socket
        |> put_flash(:info, "This conversation was deleted.")
        |> push_navigate(to: ~p"/chat")
      else
        socket
      end

    {:noreply, socket}
  end

  # ── Events ───────────────────────────────────────────────────────

  def handle_event("send_message", %{"body" => body}, socket) do
    attrs = %{"body" => body, "conversation_id" => socket.assigns.conversation.id}

    case Chat.create_message(socket.assigns.current_scope, attrs) do
      {:ok, _message} ->
        Chat.mark_as_read(socket.assigns.current_scope, socket.assigns.conversation.id)
        {:noreply, assign(socket, :draft_text, "")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not send message")}
    end
  end

  def handle_event("edit_message", %{"id" => id}, socket) do
    message = Enum.find(socket.assigns.messages.result, &(to_string(&1.id) == id))

    {:noreply,
     socket
     |> assign(:editing_message_id, message.id)
     |> assign(:draft_text, message.body)
     |> push_event("set_textarea", %{id: "message-input", value: message.body})}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply,
     socket
     |> assign(:editing_message_id, nil)
     |> assign(:draft_text, "")
     |> push_event("set_textarea", %{id: "message-input", value: ""})}
  end

  def handle_event("update_message", %{"body" => body}, socket) do
    message =
      Enum.find(socket.assigns.messages.result, &(&1.id == socket.assigns.editing_message_id))

    case Chat.update_message(socket.assigns.current_scope, message, %{"body" => body}) do
      {:ok, _message} ->
        {:noreply,
         socket
         |> assign(:editing_message_id, nil)
         |> assign(:draft_text, "")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update message")}
    end
  end

  def handle_event("delete_message", %{"id" => id}, socket) do
    message = Enum.find(socket.assigns.messages.result, &(to_string(&1.id) == id))

    case Chat.delete_message(socket.assigns.current_scope, message) do
      {:ok, _} -> {:noreply, socket}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Could not delete message")}
    end
  end

  # ── Conversation events ──────────────────────────────────────────

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

  # Private

  defp base_assigns(socket, params) do
    current_user = socket.assigns.current_scope
    q_users = Map.get(params, "q_users", "")
    q_conversations = Map.get(params, "q_conversations", "")

    prev_q =
      socket.assigns[:conversations_form] &&
        socket.assigns.conversations_form.params["q"]

    conversations_loaded? = match?(%AsyncResult{ok?: true}, socket.assigns[:conversations])
    search_changed? = prev_q != q_conversations

    socket
    |> assign(page_title: "#{current_user.user.username}'s inbox")
    |> assign(:mobile_show_chat, not Map.has_key?(params, "id"))
    |> assign(:searching_users?, q_users != "")
    |> assign(:searching_conversations?, q_conversations != "")
    |> assign(:users_form, to_form(%{"q" => q_users}))
    |> assign(:message_form, to_form(%{}))
    |> assign(:conversations_form, to_form(%{"q" => q_conversations}))
    |> assign(:messages, AsyncResult.ok([]))
    |> assign(:editing_message_id, nil)
    |> assign(:draft_text, "")
    |> assign_async(:users, fn ->
      {:ok, %{users: Chat.list_users(current_user, %{"q" => q_users})}}
    end)
    |> then(fn socket ->
      if conversations_loaded? and not search_changed? do
        socket
      else
        assign_async(socket, :conversations, fn ->
          {:ok,
           %{conversations: Chat.list_conversations(current_user, %{"q" => q_conversations})}}
        end)
      end
    end)
    |> assign(:selected_user_ids, [])
    |> assign(:group_title, "")
  end

  defp error_summary(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    |> Enum.map(fn {field, msgs} -> "#{field}: #{Enum.join(msgs, ", ")}" end)
    |> Enum.join("; ")
  end
end
