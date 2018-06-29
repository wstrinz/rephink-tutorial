defmodule RephinkWeb.TodoChannel do
  use RephinkWeb, :channel
  import RethinkDB.Query

  @table_name "todos"

  def join("todo:list", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", _payload, socket) do
    RephinkWeb.Endpoint.broadcast!(socket.topic, "pong", %{"response" => "pong"})

    {:noreply, socket}
  end

  def handle_in("todos", _payload, socket) do
    %{data: todos} = table(@table_name) |> RethinkDB.run(Rephink.DB)
    RephinkWeb.Endpoint.broadcast!(socket.topic, "todos", %{todos: todos})

    {:noreply, socket}
  end

  def handle_in("insert", %{"todo" => todo}, socket) do
    table(@table_name)
    |> insert(todo)
    |> RethinkDB.run(Rephink.DB)

    %{data: todos} = table(@table_name) |> RethinkDB.run(Rephink.DB)
    RephinkWeb.Endpoint.broadcast!(socket.topic, "todos", %{todos: todos})

    {:noreply, socket}
  end

  def handle_in("update", %{"todo" => todo}, socket) do
    table(@table_name)
    |> update(todo)
    |> RethinkDB.run(Rephink.DB)

    %{data: todos} = table(@table_name) |> RethinkDB.run(Rephink.DB)
    RephinkWeb.Endpoint.broadcast!(socket.topic, "todos", %{todos: todos})

    {:noreply, socket}
  end

  def handle_in("delete", %{"todo" => todo}, socket) do
    table(@table_name)
    |> get(todo["id"])
    |> delete()
    |> RethinkDB.run(Rephink.DB)

    %{data: todos} = table(@table_name) |> RethinkDB.run(Rephink.DB)
    RephinkWeb.Endpoint.broadcast!(socket.topic, "todos", %{todos: todos})

    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (todo:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
