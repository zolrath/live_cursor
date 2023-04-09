defmodule LiveCursorWeb.CursorsLive do
  @moduledoc false

  use LiveCursorWeb, :live_view

  alias LiveCursorWeb.Presence

  def topic(page) do
    "live_cursors:#{page}"
  end

  def render(assigns) do
    ~H"""
    <div>
      <form
        id="msgform"
        phx-submit="send_message"
        class="flex p-3 mx-auto space-x-3 bg-gradient-to-r from-pink-50 to-pink-100 rounded-xl drop-shadow-xl w-xs"
      >
        <input
          class="flex-1 py-2 px-4 text-base placeholder-gray-400 text-gray-600 bg-white rounded-lg border border-transparent shadow-md appearance-none focus:border-transparent focus:ring-2 focus:ring-pink-600 focus:outline-none"
          maxlength="30"
          aria-label="Your message"
          type="text"
          id="msg"
          name="msg"
          placeholder="Say something"
        />
        <input
          id="submit-msg"
          type="submit"
          class="flex-shrink-0 py-2 px-4 text-base font-semibold text-white bg-pink-600 rounded-lg shadow-md hover:bg-pink-700 focus:ring-2 focus:ring-pink-500 focus:ring-offset-2 focus:ring-offset-pink-200 focus:outline-none cursor-none"
          value="Change"
        />
      </form>
      <section>
        <ul class="list-none" id="cursors" phx-hook="TrackClientCursor">
          <%= for user <- @users do %>
            <% color = LiveCursor.Color.getHSL(user.name) %>
            <li
              style={"color: #{color}; left: #{x}; top: #{y}"}
              style={"color: #{color}; left: #{user.x}%; top: #{user.y}%"}
              class={"flex flex-col absolute pointer-events-none whitespace-nowrap overflow-hidden"}
            >
              <svg
                width="21px"
                height="21px"
                version="1.1"
                xmlns="http://www.w3.org/2000/svg"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                viewBox="8.2 4.9 11.6 16"
              >
                <polygon fill="black" points="8.2,20.9 8.2,4.9 19.8,16.5 13,16.5 12.6,16.6"></polygon>
                <polygon fill="currentColor" points="9.2,7.3 9.2,18.5 12.2,15.6 12.6,15.5 17.4,15.5">
                </polygon>
              </svg>
              <span style={"background-color: #{color};"} class="px-1 mt-1 ml-4 text-sm text-white">
                <%= user.name %>
              </span>
              <span
                style={"background-color: #{color};"}
                class="py-0 px-1 mt-1 text-sm text-left text-green-50 rounded-br-md opacity-80 fit-content"
              >
                <%= user.msg %>
              </span>
            </li>
          <% end %>
        </ul>
      </section>
    </div>
    """
  end

  def simplify_presence(socket) do
    Presence.list(topic(socket.assigns.page))
    |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    users = simplify_presence(socket)

    updated =
      socket
      |> assign(users: users)
      |> assign(socket_id: socket.id)

    {:noreply, updated}
  end

  def handle_event("cursor-move", %{"x" => x, "y" => y}, socket) do
    update_presence(socket.assigns.page, socket.assigns.name, %{x: x, y: y})
    {:noreply, socket}
  end

  def handle_event("send_message", %{"msg" => msg}, socket) do
    update_presence(socket.assigns.page, socket.assigns.name, %{msg: msg})
    {:noreply, socket}
  end

  def update_presence(page, key, payload) do
    metas =
      Presence.get_by_key(topic(page), key)[:metas]
      |> List.first()
      |> Map.merge(payload)

    Presence.update(self(), topic(page), key, metas)
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_new(:name, fn -> "Unknown User" end)
      |> assign_new(:page, fn -> "Unknown Page" end)
      |> assign(users: [])

    socket =
      if connected?(socket) do
        topic = topic(socket.assigns.page)
        LiveCursorWeb.Endpoint.subscribe(topic)

        Presence.track(self(), topic, socket.assigns.name, %{
          socket_id: socket.id,
          name: socket.assigns.name,
          msg: "",
          x: 0,
          y: 0
        })

        initial_users = simplify_presence(socket)
        assign(socket, users: initial_users)
      else
        socket
      end

    {:ok, socket}
  end
end
