defmodule Monedge.AccountController do
  use Monedge.Web, :controller
  alias Monedge.Account
  NimbleCSV.define(MyParser, separator: "\t", escape: "\"")

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

  def upload(conn, %{"id" => label}) do
    account = Repo.get_by(Monedge.Account, label: label)
    changeset = Account.changeset(account)
    render conn, "upload.html", changeset: changeset, account: account
  end

def extract [date, desc,amount, currency | _] do
  %{date: date, description: desc, amount: amount, currency: currency}
end

def upload_file(conn, %{"account"=>account, "id"=>id}) do
    upload = account["transfile"]
    {:ok, file} = File.open(upload.path, [:read])

    f = fn [d, a | tail] -> %{d: d, a: a} end

    lines = IO.stream(file, :line)
    |> Stream.map(&String.rstrip/1)
    |> Stream.map(&(String.replace(&1, "\"", "")))
    |> Stream.map(&(String.split(&1,"\t")))
    |> Stream.map(&extract/1)
    |> Enum.to_list

    # todo assoc account id  into transaction rather than url param

    render conn, "uploaded.html", id: id, lines: lines
end

def uploaded(conn, %{"lines" => lines, "id"=>id}) do
  render(conn, "uploaded.html",  id: id, lines: lines)
end



end
