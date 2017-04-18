defmodule Monedge.TransactionController do
  require Logger
  use Monedge.Web, :controller

  alias Monedge.Transaction
  alias Monedge.Category


  def index(conn, _params) do
    transactions = Repo.all(Transaction) |> Repo.preload(:account)|>Repo.preload(:category)|>Monedge.Repo.preload(:suggestion)
    render(conn, "index.html", transactions: transactions)
  end

  def new(conn, _params) do
    changeset = Transaction.changeset(%Transaction{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"transaction" => transaction_params}) do
    changeset = Transaction.changeset(%Transaction{}, transaction_params)

    case Repo.insert(changeset) do
      {:ok, _transaction} ->
        conn
        |> put_flash(:info, "Transaction created successfully.")
        |> redirect(to: transaction_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Repo.get!(Transaction, id)
    render(conn, "show.html", transaction: transaction)
  end

  def edit(conn, %{"id" => id}) do
    transaction = Repo.get!(Transaction, id)|> Repo.preload(:account)|>Repo.preload(:category)|>Monedge.Repo.preload(:suggestion)
    categories = Repo.all(Category) |> Enum.map (fn m -> {m.name, m.id} end)
    changeset = Transaction.changeset(transaction) |> Map.put(:categories, categories)
    render(conn, "edit.html", transaction: transaction, changeset: changeset)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Repo.get!(Transaction, id)
    changeset = Transaction.changeset(transaction, transaction_params)

    case Repo.update(changeset) do
      {:ok, transaction} ->
        conn
        |> put_flash(:info, "Transaction updated successfully.")
        |> redirect(to: transaction_path(conn, :show, transaction))
      {:error, changeset} ->
        render(conn, "edit.html", transaction: transaction, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    transaction = Repo.get!(Transaction, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(transaction)

    conn
    |> put_flash(:info, "Transaction deleted successfully.")
    |> redirect(to: transaction_path(conn, :index))
  end

def train(conn, _) do
  transactions = Monedge.Repo.all(Monedge.Transaction) |> Monedge.Repo.preload(:account)|>Monedge.Repo.preload(:category)|>Monedge.Repo.preload(:suggestion)
  fil = Enum.filter(transactions, fn t -> t.category.name != "Unclassified" end)
  bays = Enum.reduce(fil, SimpleBayes.init() , fn(x, acc) -> SimpleBayes.train(acc, String.to_atom(x.category.name), x.description)  end)
  upd_transactions = apply_model(bays, transactions)
  transactions = Monedge.Repo.all(Monedge.Transaction) |> Monedge.Repo.preload(:account)|>Monedge.Repo.preload(:category)
  render(conn, "index.html", transactions: transactions)
end



  def apply_model(bays, transactions) do
    Logger.info "apply model"
    trans = Enum.filter(transactions, fn t -> t.category.name == "Unclassified" end)
    Logger.info "trans: #{inspect(trans)}"

    classified = Enum.map(trans, fn t ->
      select_category_name = SimpleBayes.classify_one(bays, t.description)
       select_category = Repo.get_by(Category, name: Atom.to_string(select_category_name))
      Logger.info "cat: #{inspect(select_category)}"
      transaction = Repo.get!(Transaction, t.id)
      changeset = Transaction.changeset(transaction, %{category_id: select_category.id})
      Repo.update(changeset)
    end)
  end
end
