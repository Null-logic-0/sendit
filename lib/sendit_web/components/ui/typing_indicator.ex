defmodule SenditWeb.UI.TypingIndicator do
  use SenditWeb, :html

  def typing_indicator(assigns) do
    ~H"""
    <div class="chat-bubble flex items-center gap-1 py-3">
      <span class="loading loading-dots loading-sm"></span>
    </div>
    """
  end
end
