defmodule SenditWeb.UI.EmptyState do
  @moduledoc """
  Reusable Empty State UI component.

  Used to display a consistent "no data" or "empty result" state across the app,
  with optional icon, title, description, and action slot (CTA button/link).

  Example usage:

      <.empty_state
        icon="hero-user-group"
        title="No users found"
        description="Start by inviting your first team member."
      >
        <:action>
          <.link navigate={~p"/users/new"} class="btn btn-primary">
            Add User
          </.link>
        </:action>
      </.empty_state>
  """
  use SenditWeb, :html

  @doc """
  Renders an empty state component.

  ## Props

    * `:icon` - (string, required) Heroicon name to display
    * `:title` - (string, required) Main heading text
    * `:description` - (string, optional) Supporting helper text
    * `:class` - (string, optional) Extra wrapper classes

  ## Slots

    * `:action` - Optional call-to-action content (button/link)
  """

  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :class, :string, default: ""

  slot :action, required: false

  def empty_state(assigns) do
    ~H"""
    <div class={[
      "flex flex-col items-center justify-center text-center",
      @class
    ]}>
      <div class="mb-5 flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
        <.icon
          name={@icon}
          class="h-8 w-8 text-primary"
        />
      </div>

      <h3 class="text-lg font-semibold text-base-content">
        {@title}
      </h3>

      <p class="mt-2 max-w-sm text-sm leading-6 text-base-content/70">
        {@description}
      </p>

      <%= if @action != [] do %>
        <div class="mt-6">
          {render_slot(@action)}
        </div>
      <% end %>
    </div>
    """
  end
end
