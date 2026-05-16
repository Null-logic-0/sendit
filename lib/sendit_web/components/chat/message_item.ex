defmodule SenditWeb.Chat.MessageItem do
  use SenditWeb, :html

  def message_item(assigns) do
    ~H"""
    <% own? = @message.user_id == @current_scope.user.id %>
    <% editing? = @editing_message_id == @message.id %>
    <% seen? =
      own? && @is_last &&
        Enum.any?(@read_timestamps, fn {user_id, last_read_at} ->
          user_id != @current_scope.user.id &&
            last_read_at != nil &&
            DateTime.compare(last_read_at, @message.inserted_at) != :lt
        end) %>
    <div
      id={"message-#{@message.id}"}
      class={["chat", if(own?, do: "chat-end", else: "chat-start")]}
    >
      <div class="chat-image avatar">
        <div class="w-10 rounded-full">
          <%= if own? do %>
            <img src={@current_scope.user.avatar} />
          <% else %>
            <img src={@message.user.avatar} />
          <% end %>
        </div>
      </div>
      <div class="chat-header mb-0.5">
        <%= if own? do %>
          <span class="text-xs opacity-50">{@current_scope.user.full_name}</span>
        <% else %>
          <span class="text-xs opacity-50">{@message.user.full_name}</span>
        <% end %>
      </div>
      <div class={[
        "chat-bubble",
        if(own?, do: "chat-bubble-primary", else: ""),
        if(editing?, do: "ring-2 ring-warning", else: "")
      ]}>
        <p class="whitespace-pre-wrap break-words">{@message.body}</p>
      </div>
      <div class="chat-footer text-[10px] flex items-center gap-1 mt-0.5">
        <span class="opacity-60">{Calendar.strftime(@message.inserted_at, "%H:%M")}</span>
        <%= if @message.inserted_at != @message.updated_at do %>
          <span class="italic">· edited</span>
        <% end %>
        <%= if seen? do %>
          <span class="flex items-center gap-0.5 text-primary opacity-80">
            <.icon name="hero-check-circle" class="size-3" /> Seen
          </span>
        <% end %>
        <%= if own? do %>
          <div class="dropdown dropdown-end ml-1">
            <.button tabindex="0" role="button" class="btn btn-ghost btn-sm btn-circle">
              <.icon name="hero-ellipsis-horizontal" class="size-4" />
            </.button>
            <ul tabindex="-1" class="dropdown-content bg-base-100 rounded-box z-10 w-24 p-2 shadow-sm">
              <li>
                <.button
                  type="button"
                  phx-click="edit_message"
                  phx-value-id={@message.id}
                  class="btn btn-ghost btn-xs w-full justify-start"
                  title="Edit"
                >
                  <.icon name="hero-pencil" class="size-3.5" /> Edit
                </.button>
              </li>
              <li>
                <.button
                  type="button"
                  phx-click="delete_message"
                  phx-value-id={@message.id}
                  data-confirm="Delete this message?"
                  class="btn btn-ghost btn-xs w-full justify-start text-error"
                  title="Delete"
                >
                  <.icon name="hero-trash" class="size-3.5" /> Delete
                </.button>
              </li>
            </ul>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
