defmodule SenditWeb.AuthLayout do
  @moduledoc """
  Shared authentication layout used for login, registration, and other public auth flows.

  Provides a two-column responsive layout:

  - Left: marketing panel (desktop only)
  - Right: auth content container

  Features:
  - Theme toggle integration
  - Flash message rendering
  - Responsive mobile-first behavior
  - Slot-based content injection
  """

  use SenditWeb, :html

  import SenditWeb.UI.{
    FlashGroup,
    ThemeToggle,
    AppLogo
  }

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil

  slot :inner_block, required: true

  def auth_layout(assigns) do
    ~H"""
    <div class="grid min-h-screen md:grid-cols-2 bg-base-200">
      <aside class="relative hidden md:block">
        <div class="absolute inset-0 bg-primary" />

        <div class="relative z-10 flex h-full flex-col justify-between p-10 text-primary-content">
          <.app_logo link={~p"/"} />

          <ul class="space-y-3 text-sm text-primary-content/90">
            <li>· Realtime messaging that feels instant</li>
            <li>· Direct messages and group chats</li>
            <li>· Presence, typing, read receipts</li>
            <li>· Beautiful dark and light themes</li>
          </ul>
        </div>
      </aside>

      <div class="flex flex-col">
        <div class="flex items-center justify-end p-4">
          <.theme_toggle />
        </div>

        <div class="flex flex-1 items-center justify-center px-6 py-10">
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>

    <.flash_group flash={@flash} />
    """
  end
end
