defmodule RephinkWeb.PageController do
  use RephinkWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
