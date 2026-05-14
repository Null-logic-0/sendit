defmodule SenditWeb.HomePage do
  use SenditWeb, :live_view

  import SenditWeb.HomePage.{
    LandingHeader,
    LandingFooter
  }

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.landing_header />

    <main>
      <section class="mx-auto max-w-7xl px-6 pt-4 pb-16 text-center">
        <div class="badge border-primary rounded-xl gap-2 p-3">
          <.icon name="hero-sparkles" class="size-4 text-primary" />
          <span class="text-sm font-semibold text-primary">Beta Version</span>
        </div>

        <h1 class="mt-6 text-5xl md:text-6xl font-semibold tracking-tight">
          Conversations, refined.
        </h1>

        <p class="mx-auto mt-5 max-w-xl text-base-content/70">
          A realtime chat workspace built for focus. Direct messages, groups, presence,
          and read receipts — all wrapped in a beautiful, minimal interface.
        </p>

        <div class="mt-8 flex items-center justify-center">
          <.link navigate={~p"/chat"} class="btn btn-primary">
            Start chatting <.icon name="hero-arrow-right" class="h-4 w-4" />
          </.link>
        </div>

        <div class="relative mx-auto mt-16 max-w-5xl">
          <div class="card border border-base-300 bg-base-100 shadow-xl overflow-hidden">
            <.preview_mock />
          </div>
          <div class="pointer-events-none absolute inset-x-10 -bottom-6 h-12 rounded-full bg-primary/20 blur-2xl" />
        </div>
      </section>

      <section class="mx-auto grid max-w-6xl gap-4 px-6 pb-24 md:grid-cols-3">
        <.feature_card
          icon="hero-bolt"
          title="Realtime by default"
          body="Messages, typing indicators and presence update instantly across devices."
        />
        <.feature_card
          icon="hero-user-group"
          title="Groups that scale"
          body="Create groups, add teammates, and keep conversations organized."
        />
        <.feature_card
          icon="hero-shield-check"
          title="Built for trust"
          body="Delivery and read receipts so you always know where things stand."
        />
      </section>
    </main>

    <.landing_footer />
    """
  end

  defp preview_mock(assigns) do
    ~H"""
    <div class="grid grid-cols-1 md:grid-cols-[260px_1fr] md:h-[420px] h-[70vh] text-left border border-base-300/60 rounded-xl overflow-hidden">
      <div class="border-b md:border-b-0 md:border-r border-base-300/60 bg-base-200/60 p-3 overflow-y-auto">
        <p class="px-2 py-1 text-xs font-semibold uppercase tracking-wider text-base-content/60">
          Chats
        </p>

        <div class="space-y-1 mt-2">
          <.conversation_row
            name="Alex Kim"
            msg="Pushed the redesign 🚀"
            unread={2}
            online={true}
            active={true}
          />
          <.conversation_row
            name="Product Team"
            msg="Mia: standup in 5"
            unread={0}
            online={true}
            group={true}
          />
          <.conversation_row
            name="Mia Chen"
            msg="Sounds good, talk later 👋"
            unread={0}
            online={true}
          />
          <.conversation_row
            name="Weekend Trip"
            msg="Noah: booked the cabin!"
            unread={7}
            online={false}
            group={true}
          />
        </div>
      </div>

      <div class="flex flex-col bg-base-100 min-h-0">
        <div class="flex items-center border-b border-base-300/60 px-4 sm:px-5 py-3">
          <.avatar name="Alex Kim" online={true} />
          <div class="ml-3">
            <div class="text-sm font-medium">Alex Kim</div>
            <div class="text-[11px] text-success">online</div>
          </div>
        </div>

        <div class="flex-1 overflow-y-auto p-3 sm:p-5 space-y-2">
          <.bubble side="left" name="Alex Kim">
            Hey! Did you get a chance to look at the Figma file?
          </.bubble>

          <.bubble side="right" name="You">
            Yes — the new sidebar feels much cleaner.
          </.bubble>

          <.bubble side="left" name="Alex Kim">
            Right? I dropped the dividers and used more whitespace.
          </.bubble>

          <.bubble side="right" name="You">
            Love it ✨
          </.bubble>

          <div class="chat chat-start">
            <.typing_indicator />
          </div>
        </div>

        <div class="border-t border-base-300/60 p-2 sm:p-3">
          <div class="flex gap-2 items-center w-full">
            <input
              class="input input-bordered rounded-xl flex-1 text-sm"
              placeholder="Message Alex"
            />

            <.button class="btn btn-primary btn-circle" navigate={~p"/chat"}>
              <.icon name="hero-paper-airplane" />
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp conversation_row(assigns) do
    assigns =
      assigns
      |> Map.put_new(:unread, 0)
      |> Map.put_new(:online, false)
      |> Map.put_new(:group, false)
      |> Map.put_new(:active, false)

    ~H"""
    <div class={[
      "flex items-center gap-3 rounded-lg p-2 cursor-pointer hover:bg-base-200",
      @active && "bg-base-100 shadow-sm"
    ]}>
      <.avatar name={@name} online={@online} group={@group} size="sm" />
      <div class="min-w-0 flex-1">
        <div class="flex items-center justify-between">
          <span class="truncate text-sm font-medium">{@name}</span>
          <span class="text-[10px] text-base-content/50">2m</span>
        </div>
        <p class="truncate text-xs text-base-content/60">{@msg}</p>
      </div>
      <%= if @unread > 0 do %>
        <div class="badge badge-primary rounded-full text-xs p-2 badge-xs">{@unread}</div>
      <% end %>
    </div>
    """
  end

  defp feature_card(assigns) do
    ~H"""
    <div class="card card-border bg-base-100 shadow-sm">
      <div class="card-body gap-3 p-6">
        <div class="grid h-9 w-9 place-items-center rounded-lg bg-primary/10 text-primary">
          <.icon name={@icon} class="h-4 w-4" />
        </div>
        <h3 class="card-title text-base">{@title}</h3>
        <p class="text-sm text-base-content/70">{@body}</p>
      </div>
    </div>
    """
  end

  defp avatar(assigns) do
    assigns =
      assigns
      |> Map.put_new(:online, false)
      |> Map.put_new(:group, false)
      |> Map.put_new(:size, "md")

    avatar_url =
      "https://api.dicebear.com/9.x/adventurer/svg?seed=#{URI.encode(assigns.name)}"

    assigns =
      assigns
      |> Map.put(:avatar_url, avatar_url)

    ~H"""
    <div class={["avatar", @online && "avatar-online"]}>
      <div class={[
        "rounded-full overflow-hidden",
        @size == "sm" && "w-8",
        @size == "md" && "w-10"
      ]}>
        <%= if @group do %>
          <div class="flex h-full w-full items-center justify-center bg-base-300">
            <.icon name="hero-user-group" class="h-4 w-4" />
          </div>
        <% else %>
          <img
            src={@avatar_url}
            alt={@name}
            class="h-full w-full object-cover"
          />
        <% end %>
      </div>
    </div>
    """
  end

  defp bubble(assigns) do
    ~H"""
    <div class={["chat", @side == "right" && "chat-end", @side == "left" && "chat-start"]}>
      <div class={[
        "chat-bubble",
        @side == "right" && "chat-bubble-primary",
        @side == "left" && "chat-bubble-ghost"
      ]}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp typing_indicator(assigns) do
    ~H"""
    <div class="chat-bubble flex items-center gap-1 py-3">
      <span class="loading loading-dots loading-sm"></span>
    </div>
    """
  end
end
