defmodule SenditWeb.Chat.ConversationList do
  use SenditWeb, :html

  def conversation_list(assigns) do
    ~H"""
    <ul class="w-full overflow-y-auto">
      <%= for  item <- @items do %>
        <li class="flex items-center gap-3 px-4 py-3 hover:bg-base-200 w-full text-left">
          <img src={item.avatar} class="rounded-full object-cover w-10 h-10" />
          <div class="flex flex-col">
            <p class="text-sm font-medium truncate">
              {item.full_name}
            </p>
            <p class="text-xs font-medium ">
              @{item.username}
            </p>
          </div>
        </li>
      <% end %>
    </ul>
    """
  end
end
