defmodule Monedge.PageController do
  use Monedge.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
