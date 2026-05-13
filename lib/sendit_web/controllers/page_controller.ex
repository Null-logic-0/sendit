defmodule SenditWeb.PageController do
  use SenditWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
