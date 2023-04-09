defmodule LiveCursorWeb.AssignName do
  import Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    socket = assign(socket, name: LiveCursor.Name.generate())
    {:cont, socket}
  end
end
