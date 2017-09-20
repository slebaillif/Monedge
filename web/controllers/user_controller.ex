defmodule Monedge.UserController do
    require Logger
    use Monedge.Web, :controller
    use Timex
    alias Monedge.User
  
    def index(conn, _params) do
      users = Repo.all(Monedge.User)
      render conn, "index.html", users: users
    end
  
    def show(conn, %{"id" => firstName}) do
        user = Repo.get_by(Monedge.User, firstName: firstName)
        render conn, "show.html", user: user
    end
  
    def new(conn, _params) do
      changeset = User.changeset(%User{})
      render conn, "new.html", changeset: changeset
    end
  
    def create(conn, %{"user" => user_params}) do
      changeset = User.changeset(%User{}, user_params)
      case Repo.insert(changeset) do
  
        {:ok, user} -> conn
        |> put_flash(:info, "User #{user.firstName} #{user.lastName}created")
        |> redirect(to: user_path(conn, :index, id: user.firstName))
  
        {:error, changeset} -> render(conn, "new.html", changeset: changeset)
      end
    end
   
  end
  