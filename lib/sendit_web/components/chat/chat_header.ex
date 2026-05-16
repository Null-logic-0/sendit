defmodule SenditWeb.Chat.ChatHeader do
  use SenditWeb, :html

  import SenditWeb.Chat.ChatInfoDrawer

  def chat_header(assigns) do
    ~H"""
    <div class="sticky w-full top-0 z-10 pr-2 py-2 border-b border-base-200 bg-base-100 flex items-center gap-2">
      <.link navigate={~p"/chat"} class="btn btn-ghost btn-sm btn-circle shrink-0">
        <.icon name="hero-chevron-left" class="size-6" />
      </.link>

      <%= if @conversation.is_group do %>
        <div class="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center shrink-0">
          <.icon name="hero-user-group" class="size-7 text-primary" />
        </div>
      <% else %>
        <% u = Enum.find(@conversation.users, &(&1.id != @current_scope.user.id)) %>
        <img src={u.avatar} class="w-12 h-12 rounded-full object-cover shrink-0" />
      <% end %>

      <div>
        <p class="text-lg font-semibold truncate">{@display_name}</p>
        <p class="text-xs text-base-content/50 truncate">{@display_subtitle}</p>
      </div>

      <.chat_info_drawer
        current_scope={@current_scope}
        conversation={@conversation}
        display_name={@display_name}
        display_subtitle={@display_subtitle}
      />
    </div>
    """
  end
end
