defmodule SenditWeb.UI.Avatar do
  use SenditWeb, :html

  attr :src, :string, required: true
  attr :alt, :string, default: "avatar"

  # sizes: xs | sm | md | lg | xl
  attr :size, :string, default: "md"

  attr :online?, :boolean, default: false
  attr :show_status?, :boolean, default: true

  attr :class, :string, default: ""

  def avatar(assigns) do
    ~H"""
    <div class={["relative shrink-0", @class]}>
      <img
        src={@src}
        alt={@alt}
        class={[
          "rounded-full object-cover",
          avatar_size(@size)
        ]}
      />

      <%= if @show_status? do %>
        <span class={[
          "absolute bottom-0 right-0 rounded-full animate-pulse border-2 border-base-100",
          status_size(@size),
          if(@online?, do: "bg-green-500", else: "bg-yellow-500")
        ]} />
      <% end %>
    </div>
    """
  end

  #  Avatar Sizes

  defp avatar_size("xs"), do: "w-6 h-6"
  defp avatar_size("sm"), do: "w-8 h-8"
  defp avatar_size("md"), do: "w-12 h-12"
  defp avatar_size("lg"), do: "w-16 h-16"
  defp avatar_size("xl"), do: "w-24 h-24"

  defp avatar_size(_), do: avatar_size("md")

  #  Status Dot Sizes

  defp status_size("xs"), do: "w-2 h-2"
  defp status_size("sm"), do: "w-2.5 h-2.5"
  defp status_size("md"), do: "w-3 h-3"
  defp status_size("lg"), do: "w-4 h-4"
  defp status_size("xl"), do: "w-5 h-5"

  defp status_size(_), do: status_size("md")
end
