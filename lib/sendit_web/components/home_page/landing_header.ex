defmodule SenditWeb.HomePage.LandingHeader do
  @moduledoc """
  Public marketing navigation header used across unauthenticated pages.

  The landing header provides:
  - Application branding
  - Authentication entry points
  - Responsive navigation behavior

  This component is intended for:
  - Landing pages
  - Marketing pages
  - Authentication screens
  - Public-facing layouts

  The layout is optimized for mobile and desktop experiences
  using TailwindCSS and DaisyUI utilities.
  """

  use SenditWeb, :html

  import SenditWeb.UI.AppLogo

  @doc """
  Renders the public landing page header.

  ## Examples

      <.landing_header />

  """
  def landing_header(assigns) do
    ~H"""
    <header class="navbar px-2 sm:px-4 lg:px-6 py-3">
      <div class="flex w-full items-center justify-between">
        <div class="flex items-center">
          <.app_logo link={~p"/"} />
        </div>

        <div class="flex items-center gap-2 sm:gap-4">
          <.link
            navigate={~p"/users/log-in"}
            class="btn btn-ghost btn-sm sm:btn-md"
          >
            <span class="hidden sm:inline">Sign in</span>
            <span class="sm:hidden">Login</span>
          </.link>

          <.link navigate={~p"/users/register"} class="btn btn-primary btn-sm sm:btn-md">
            <span class="sm:hidden"> Register </span>
            <span class="hidden sm:inline"> Get Started <span aria-hidden="true">&rarr;</span></span>
          </.link>
        </div>
      </div>
    </header>
    """
  end
end
