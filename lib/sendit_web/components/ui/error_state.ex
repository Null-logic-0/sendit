defmodule SenditWeb.UI.ErrorState do
  @moduledoc """
  Reusable Error State UI component.

  Used to display consistent error screens across the app
  (failed requests, empty responses due to errors, system issues).

  Supports optional icon, description, and action slot (retry / navigation CTA).

  Example:

      <.error_state
        title="Something went wrong"
        description="We couldn't load your data. Please try again."
      >
        <:action>
          <button phx-click="retry" class="btn btn-error btn-outline">
            Try again
          </button>
        </:action>
      </.error_state>
  """

  use SenditWeb, :html

  import Phoenix.Component

  @doc """
  Renders an error state component.

  ## Props

    * `:title` - (string, required) Main error message
    * `:description` - (string, optional) Supporting explanation text
    * `:icon` - (string, optional) Heroicon name (default: warning icon)
    * `:class` - (string, optional) Extra wrapper classes

  ## Slots

    * `:action` - Optional action area (retry button, navigation link, etc.)
  """

  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :icon, :string, default: "hero-exclamation-triangle"
  attr :class, :string, default: ""

  slot :action, required: false

  def error_state(assigns) do
    ~H"""
    <div class={[
      "flex flex-col items-center justify-center text-center",
      @class
    ]}>
      <div class="mb-4 flex h-20 w-20 items-center justify-center rounded-full border border-error/20 bg-error/10">
        <.icon name={@icon} class="size-10 text-error" />
      </div>

      <h2 class="text-xl font-bold tracking-tight text-base-content">
        {@title}
      </h2>

      <%= if @description do %>
        <p class="max-w-md text-sm leading-7 text-base-content/70">
          {@description}
        </p>
      <% end %>

      <%= if @action != [] do %>
        <div class="mt-8">
          {render_slot(@action)}
        </div>
      <% end %>
    </div>
    """
  end
end
