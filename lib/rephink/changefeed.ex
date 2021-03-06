defmodule Rephink.Changefeed do
  use RethinkDB.Changefeed
  import RethinkDB.Query

  @table_name "todos"
  @topic "todo:list"

  def start_link(db, gen_server_opts \\ [name: Rephink.Changefeed]) do
    RethinkDB.Changefeed.start_link(__MODULE__, db, gen_server_opts)
  end

  def init(db) do
    query = table(@table_name)
    %{data: data} = RethinkDB.run(query, db)

    todos =
      Enum.map(data, fn x ->
        {x["id"], x}
      end)
      |> Enum.into(%{})

    {:subscribe, changes(query), db, {db, todos}}
  end

  def handle_update(data, {db, todos}) do
    todos =
      Enum.reduce(data, todos, fn
        %{"new_val" => nv, "old_val" => ov}, p ->
          case nv do
            nil ->
              Map.delete(p, ov["id"])

            %{"id" => id} ->
              Map.put(p, id, nv)
          end
      end)

    RephinkWeb.Endpoint.broadcast!(@topic, @table_name, %{todos: Map.values(todos)})

    {:next, {db, todos}}
  end

  def handle_call(:todos, _from, {db, todos}) do
    RephinkWeb.Endpoint.broadcast!(@topic, @table_name, %{todos: Map.values(todos)})

    {:reply, Map.values(todos), {db, todos}}
  end

  def handle_call({:insert, todo}, _from, {db, todos}) do
    table(@table_name)
    |> insert(todo)
    |> RethinkDB.run(db)

    {:reply, Map.values(todos), {db, todos}}
  end

  def handle_call({:update, todo}, _from, {db, todos}) do
    table(@table_name)
    |> update(todo)
    |> RethinkDB.run(db)

    {:reply, Map.values(todos), {db, todos}}
  end

  def handle_call({:delete, todo}, _from, {db, todos}) do
    table(@table_name)
    |> filter(todo)
    |> delete()
    |> RethinkDB.run(db)

    {:reply, Map.values(todos), {db, todos}}
  end
end
