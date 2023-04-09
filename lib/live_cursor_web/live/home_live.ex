defmodule LiveCursorWeb.HomeLive do
  use LiveCursorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page: "home")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="pb-8 text-3xl text-center">Live Cursor Chat</h1>
    <%= live_render(@socket, LiveCursorWeb.CursorsLive, id: "cursor-#{@socket.id}") %>
    """
  end
end
