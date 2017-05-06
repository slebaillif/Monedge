defmodule Monedge.TransactionController do
  require Logger
  use Monedge.Web, :controller

  alias Monedge.Transaction
  alias Monedge.Category

def d3test(conn, _params) do
  transactions = Repo.all( from t in Monedge.Transaction,
  join: c in assoc(t, :category),
  # where: t.category_id in [1,2,3,4,5,6,7,8,9],
  group_by: c.name,
  select: [c.name, sum(t.amount)]  )

  sorted = Enum.filter(transactions, &(Enum.at(&1,1) <0))
          |>Enum.sort(&(Enum.at(&1,1) <= Enum.at(&2,1)))
          |>Enum.take(4)

  Logger.info ("sorted: #{inspect(sorted)}")

  render(conn, "d3test.html",transactions: sorted)
end

  def index(conn, _params) do
    transactions = Repo.all(Transaction) |> Repo.preload(:account)|>Repo.preload(:category)|>Monedge.Repo.preload(:suggestion)
    render(conn, "index.html", transactions: transactions)
  end

  def unclassified(conn, _params) do
    transactions = Repo.all( from t in Monedge.Transaction,  where: t.category_id ==6,  select: t  )
    |> Repo.preload(:account)
    |>Repo.preload(:category)
    |>Monedge.Repo.preload(:suggestion)

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
  apply_model(bays, transactions)
  redirect(conn, to: transaction_path(conn, :unclassified))
end

def guess(conn, %{"id" => id}) do
  transaction = Repo.get!(Transaction, id)
  changeset = Transaction.changeset(transaction, %{category_id: transaction.suggestion_id})
  Repo.update(changeset)
  train(conn, nil)
end

def sanitize_description(desc) do
  String.replace(desc, ~r/[0-9]/, "")
  |> String.replace( ~r/\./, "")
  |> String.replace( ~r/\./, "")
  |> String.replace( ~r/GBP/, "")
  |> String.replace( ~r/GB/, "")
  |> String.replace( ~r/PURCHASE/, "")
  |> String.replace( ~r/OUTGOING FASTER PAYMENT/, "")
  |> String.replace( ~r/STANDING ORDER/, "")
  |> String.replace( ~r/INCOMING CHAPS/, "")
  |> String.replace( ~r/TRANSFER CHAPS/, "")
  |> String.replace( ~r/DIRECT DEBIT/, "")
  |> String.replace( ~r/PAYPAL/, "")
end

  def apply_model(bays, transactions) do
    Logger.info "apply model"
    # trans = Enum.filter(transactions, fn t -> t.category.name == "Unclassified" end)
    # Logger.info "transactions: #{inspect(transactions)}"

    classified = Enum.map(transactions, fn t ->
      first_result= SimpleBayes.classify(bays, sanitize_description(t.description))
      Logger.info "first_result: #{inspect(first_result)}"
      select_category_name = first_result
                            |> Keyword.keys
                            |> List.first
      val = first_result
            |>Keyword.get(select_category_name)

      select_category = case val do
        0.0 ->  Repo.get_by(Category, name: "Unclassified")
          _ ->  Repo.get_by(Category, name: Atom.to_string(select_category_name))
      end

      Logger.info "cat: #{inspect(select_category)}"
      transaction = Repo.get!(Transaction, t.id)
      changeset = Transaction.changeset(transaction, %{suggestion_id: select_category.id})
      Repo.update(changeset)
    end)
  end
end
