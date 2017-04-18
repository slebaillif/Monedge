defmodule Monedge.AccountController do
  require Logger
  use Monedge.Web, :controller
  use Timex
  alias Monedge.Account
  alias Monedge.Transaction
  alias Monedge.Category

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

def extract([date, desc,amount, currency | _], account) do
  case Timex.parse(date, "{D}-{0M}-{YYYY}") do
    {:ok, timex_date} ->{:ok, formatted_date} = Timex.format(timex_date, "{ISOdate}")
                        %{date: Ecto.Date.cast!(formatted_date), description: desc, amount: String.to_float(amount), currency: currency, account_id: account, category_id: 6, suggestion_id: 6}
    {:error, error} -> Logger.info "Error extract: #{inspect(error)}"
  end

end

def upload_file(conn, %{"account"=>account, "id"=>id}) do
    upload = account["transfile"]
    real_account = Repo.get_by(Monedge.Account, label: id)
    {:ok, file} = File.open(upload.path, [:read])

    f = fn [d, a | tail] -> %{d: d, a: a} end

    lines = IO.stream(file, :line)
    |> Stream.map(&String.rstrip/1)
    |> Stream.map(&(String.replace(&1, "\"", "")))
    |> Stream.map(&(String.split(&1,"\t")))
    |> Stream.map(&(extract(&1, real_account.id)))
    |> Enum.to_list

    lines
    |>Enum.map(&(save_transactions(&1)) )
# [head|_] =lines
# Logger.info "Var value head: #{inspect(head)}"
# save_transactions(conn, head)

    render conn, "uploaded.html", id: id, lines: lines
end

def uploaded(conn, %{"lines" => lines, "id"=>id}) do
  render(conn, "uploaded.html",  id: id, lines: lines)
end

def save_transactions(transaction_params) do
  changeset = Transaction.changeset(%Transaction{}, transaction_params)
  # case
  Repo.insert(changeset)
  # do
    # {:ok, _transaction} ->
    #   conn
    #   |> put_flash(:info, "Transaction created successfully.")
    #   |> redirect(to: transaction_path(conn, :index))
    # {:error, changeset} ->
    #   Logger.info "Error: #{inspect(changeset)}"
      # render(conn, "new.html", changeset: changeset)
  # end
end


end
