defmodule SenditWeb.UI.Modal do
  use SenditWeb, :html

  attr :id, :string, required: true
  attr :title, :string, default: nil
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <dialog id={@id} class="modal">
      <div class="modal-box p-0 max-w-lg">
        <div class="flex items-center justify-between px-4 py-3 border-b border-base-200">
          <h3 :if={@title} class="font-semibold text-sm">
            {@title}
          </h3>

          <form method="dialog">
            <button class="btn btn-sm btn-circle btn-ghost">✕</button>
          </form>
        </div>

        {render_slot(@inner_block)}
      </div>

      <form method="dialog" class="modal-backdrop">
        <button>close</button>
      </form>
    </dialog>
    """
  end
end
