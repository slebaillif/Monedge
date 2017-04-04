defmodule Monedge.AccountController do
  use Monedge.Web, :controller
  alias Monedge.Account

  def index(conn, _params) do
    accounts = Repo.all(Monedge.Account)
    render conn, "index.html", accounts: accounts
  end

  def show(conn, %{"id" => label}) do
      account = Repo.get_by(Monedge.Account, label: label)
      render conn, "show.html", account: account
  end

  def new(conn, _params) do
    changeset = Account.changeset(%Account{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"account" => user_params}) do
    changeset = Account.changeset(%Account{}, user_params)
    case Repo.insert(changeset) do

      {:ok, account} -> conn
      |> put_flash(:info, "#{account.label} created")
      |> redirect(to: account_path(conn, :index, id: account.label))

      {:error, changeset} -> render(conn, "new.html", changeset: changeset)
  end
end

end
