defmodule SenditWeb.UI.AsyncList do
  @moduledoc """
  Reusable asynchronous list component for Phoenix LiveView.

  Wraps `Phoenix.Component.async_result/1` and provides consistent handling for:

    * Loading states
    * Error states
    * Empty states
    * Rendered collections

  Designed for async-loaded resources such as:
    * conversations
    * users
    * notifications
    * search results
    * feeds

  Integrates with the shared UI state system:
    * `LoadingState`
    * `EmptyState`
    * `ErrorState`

  ## Example

      <.async_list
        assign={@users}
        empty_icon="hero-user-group"
        empty_title="No users found"
        empty_description="Try searching for another user."
      >
        <:item :let={user}>
          <div>{user.full_name}</div>
        </:item>
      </.async_list>

  ## Custom Empty State

      <.async_list assign={@messages}>
        <:empty>
          <div class="py-12 text-center">
            No messages yet.
          </div>
        </:empty>

        <:item :let={message}>
          <div>{message.body}</div>
        </:item>
      </.async_list>
  """
  use SenditWeb, :html

  import SenditWeb.UI.{
    LoadingState,
    EmptyState,
    ErrorState
  }

  @doc """
  Renders an asynchronous collection with built-in loading,
  error, and empty state handling.

  ## Props

    * `:assign` - AsyncResult assign returned from `assign_async/3`
    * `:class` - Additional classes for the rendered list wrapper
    * `:empty_icon` - Heroicon used in default empty state
    * `:empty_title` - Empty state heading
    * `:empty_description` - Empty state supporting text
    * `:loading_label` - Label displayed during loading state

  ## Slots

    * `:item` - Required item renderer (`:let={item}`)
    * `:empty` - Optional custom empty state override
  """

  attr :assign, :any,
    required: true,
    doc: "AsyncResult returned from assign_async/3"

  attr :class, :string,
    default: nil,
    doc: "Additional CSS classes for the list wrapper"

  attr :empty_icon, :string,
    default: "hero-inbox",
    doc: "Heroicon name displayed in the empty state"

  attr :empty_title, :string,
    default: "Nothing here yet",
    doc: "Primary empty state title"

  attr :empty_description, :string,
    default: nil,
    doc: "Optional supporting text for the empty state"

  attr :loading_label, :string,
    default: "Loading...",
    doc: "Text displayed during loading state"

  slot :item,
    required: true,
    doc: "Rendered for each item in the collection. Receives :let={item}"

  slot :empty,
    doc: "Optional custom empty state override"

  def async_list(assigns) do
    ~H"""
    <.async_result :let={result} assign={@assign}>
      <:loading>
        <.loading_state label={@loading_label} />
      </:loading>
      <:failed :let={{:error, reason}}>
        <.error_state
          class="my-12"
          title="Something went wrong"
          description={reason}
        />
      </:failed>

      <%= if result == [] do %>
        <%= if @empty != [] do %>
          {render_slot(@empty)}
        <% else %>
          <.empty_state
            class="my-12"
            icon={@empty_icon}
            title={@empty_title}
            description={@empty_description}
          />
        <% end %>
      <% else %>
        <ul class={["w-full", @class]}>
          <%= for entry <- result do %>
            <li>
              {render_slot(@item, entry)}
            </li>
          <% end %>
        </ul>
      <% end %>
    </.async_result>
    """
  end
end
