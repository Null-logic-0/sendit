defmodule SenditWeb.UI.AppLogo do
  @moduledoc """
  Reusable application branding component.

  Renders the WeChat logo alongside the application name and
  provides a consistent navigation entry point across the UI.

  Intended for use in:
  - Marketing headers
  - Authentication layouts
  - Application sidebars
  - Mobile navigation
  - Dashboard topbars

  The component is fully responsive and theme-aware through
  DaisyUI/Tailwind utility classes.
  """
  use SenditWeb, :html

  @doc """
  Renders the application logo with a navigational link.

  ## Examples

      <.app_logo link={~p"/"} />

      <.app_logo link={~p"/dashboard"} />

  """
  attr :link, :string,
    required: true,
    doc: "Destination path used for the logo anchor navigation."

  def app_logo(assigns) do
    ~H"""
    <a href={@link} class="flex items-center gap-2">
      <img
        src={~p"/images/logo.svg"}
        class="bg-primary rounded-lg p-2 h-10 w-10 text-white"
        alt="Sendit logo"
      />

      <span class="text-lg sm:text-xl font-semibold whitespace-nowrap">
        Sendit
      </span>
    </a>
    """
  end
end
