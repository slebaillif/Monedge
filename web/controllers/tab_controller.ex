defmodule Monedge.TabController do
    require Logger
    use Monedge.Web, :controller
    use Timex
    alias Monedge.Tab
  
    def index(conn, _params) do
      tabs = Repo.all(Monedge.Tab)
      render conn, "index.html", tabs: tabs
    end
  
    def show(conn, %{"id" => name}) do
        tab = Repo.get_by(Monedge.Tab, name: name)
        render conn, "show.html", tab: tab
    end
  
    def new(conn, _params) do
      changeset = Tab.changeset(%Tab{})
      render conn, "new.html", changeset: changeset
    end
  
    def create(conn, %{"tab" => tab_params}) do
      changeset = Tab.changeset(%Tab{}, tab_params)
      case Repo.insert(changeset) do
  
        {:ok, tab} -> conn
        |> put_flash(:info, "Tab #{tab.name} - #{tab.currency} created")
        |> redirect(to: tab_path(conn, :index, id: tab.name))
  
        {:error, changeset} -> render(conn, "new.html", changeset: changeset)
      end
    end
   
  end
  