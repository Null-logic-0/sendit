defmodule SenditWeb.UI.LoadingState do
  @moduledoc """
  Reusable loading state component.

  Displays a centered DaisyUI spinner with optional label.
  Used for page loads, async fetches, and suspended UI states.
  """

  use SenditWeb, :html

  import Phoenix.Component

  @doc """
  Renders a loading indicator.

  ## Props

    * `:label` - (string, optional) Text shown under spinner
    * `:size` - (string, optional) DaisyUI size class (default: "loading-xl")
    * `:class` - (string, optional) Extra wrapper classes
  """

  attr :label, :string, default: nil
  attr :size, :string, default: "loading-xl"
  attr :class, :string, default: ""

  def loading_state(assigns) do
    ~H"""
    <div class={[
      "flex flex-col items-center justify-center py-16 text-center",
      @class
    ]}>
      <span class={[
        "loading loading-spinner text-primary",
        @size
      ]}>
      </span>

      <%= if @label do %>
        <p class="mt-4 text-sm text-base-content/70 animate-pulse">
          {@label}
        </p>
      <% end %>
    </div>
    """
  end
end
