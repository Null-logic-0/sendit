defmodule SenditWeb.UI.Search do
  @moduledoc """
  Reusable search input component for LiveView forms.

  Designed for:
    - Live search (phx-change)
    - Filter inputs
    - Modal-based search UIs
    - Inline search bars

  Fully theme-compatible with DaisyUI + Tailwind.

  ## Features
    - Debounced input support
    - Custom event handler
    - Flexible styling via `class`
    - Works with any Phoenix form

  ## Example

      <.ui_search
        form={@form}
        placeholder="Search users..."
        change="search"
      />
  """

  use SenditWeb, :html

  @doc """
  Renders a reusable search input.

  ## Props

    * `:form` - Phoenix form (required)
    * `:field` - form field name (default: "q")
    * `:placeholder` - input placeholder text
    * `:id` - wrapper id (default: "search")
    * `:change` - phx-change event name
    * `:debounce` - debounce delay in ms (default: 500)
    * `:class` - extra wrapper classes
  """

  attr :form, :any, required: true
  attr :field, :string, default: "q"
  attr :placeholder, :string, default: "Search..."
  attr :id, :string, required: true
  attr :change, :string, required: true
  attr :debounce, :integer, default: 500
  attr :class, :string, default: ""

  def search(assigns) do
    ~H"""
    <div id={@id} class={["w-full", @class]}>
      <.form for={@form} phx-change={@change} class="w-full">
        <div class="relative w-full">
          <.icon
            name="hero-magnifying-glass"
            class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-base-content/40"
          />

          <.input
            type="search"
            name={@field}
            value={Phoenix.HTML.Form.input_value(@form, @field)}
            placeholder={@placeholder}
            autocomplete="off"
            phx-debounce={@debounce}
            class="
                  w-full rounded-xl bg-base-200
                  py-2 pl-9 pr-4 text-sm
                  placeholder:text-base-content/40
                  focus:outline-none focus:ring-2 focus:ring-primary/40
                  transition
                "
          />
        </div>
      </.form>
    </div>
    """
  end
end
