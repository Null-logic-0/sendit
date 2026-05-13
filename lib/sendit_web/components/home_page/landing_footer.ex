defmodule SenditWeb.HomePage.LandingFooter do
  @moduledoc """
  Public-facing landing page footer component.

  This component renders the global footer used across unauthenticated
  pages (landing, marketing, authentication screens).

  It is designed to be minimal, responsive, and product-grade, providing:
  - Brand identity (application name)
  - Copyright notice with dynamic year
  - External author attribution link
  - Theme switching control

  ## Design principles

  - Mobile-first responsive layout (column → row at `sm` breakpoint)
  - Low visual hierarchy to avoid distracting from primary content
  - Subtle semantic separation using muted typography
  - Compatible with DaisyUI theme system (light/dark/system)
  - Accessible external links with safe target behavior

  ## Usage

      <.landing_footer />

  ## Responsibilities

  This component is intentionally presentation-only and does not
  manage state. Theme switching and routing are delegated to
  shared UI components.

  """
  use SenditWeb, :html

  import SenditWeb.UI.ThemeToggle

  @doc """
  Renders the landing page footer.

  Displays branding, copyright, author attribution, and theme toggle.

  This footer is intended for public layouts only.
  """
  def landing_footer(assigns) do
    ~H"""
    <footer class="border-t border-base-300/60 bg-base-100">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-6 flex flex-col sm:flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-2 text-xs text-base-content/60">
          <span class="font-bold text-sm text-base-content/80">Sendit</span>
          <span>•</span>
          <p>
            <span>© {Date.utc_today().year}</span>
            <a
              href="https://github.com/Null-logic-0"
              target="_blank"
              class="hover:link hover:text-semibold hover:text-info"
            >
              Luka Tchelidze
            </a>
          </p>
        </div>

        <div class="flex items-center gap-3">
          <.theme_toggle />
        </div>
      </div>
    </footer>
    """
  end
end
