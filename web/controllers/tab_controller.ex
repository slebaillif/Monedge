defmodule Monedge.TabController do
    require Logger
    use Monedge.Web, :controller
    use Timex
    alias Monedge.Tab
    alias Monedge.Account
  
    def index(conn, _params) do
      tabs = Repo.all(Monedge.Tab)
      render conn, "index.html", tabs: tabs
    end
  
    def show(conn, %{"id" => name}) do
        tab = Repo.get_by(Monedge.Tab, name: name) |> Monedge.Repo.preload(:accounts)
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

    def assoc_accounts_edit(conn, %{"id" => id}) do
      tab = Repo.get!(Tab, id)|> Repo.preload(:accounts)|> Repo.preload(:transactions)
      accountsList = Repo.all(Account) |> Enum.map (fn m -> {m.bank, m.id} end)
      changeset = Tab.changeset(tab) |> Map.put(:accounts, accountsList)
      render(conn, "assoc_accounts.html", tab: tab, changeset: changeset)
    end
   
    def assoc_accounts_update(conn, %{"id" => id,"tab" => account_id}) do
      tab = Repo.get!(Tab, id)|> Repo.preload(:accounts)|> Repo.preload(:transactions)

      aid = account_id["account_id"]
      account = Repo.get_by(Monedge.Account, id: aid)|>Repo.preload(:user)
      Logger.info "account: #{inspect(account)}"
      accountChangeset = Account.changeset(account)
     
      Logger.info "accountChangeset: #{inspect(accountChangeset)}"
      
      updatedList = [accountChangeset] ++ tab.accounts
      Logger.info "updatedList: #{inspect(updatedList)}"
      
      changeset = Tab.changeset(tab)|>Ecto.Changeset.put_assoc(:accounts, updatedList )
      

      case Repo.update(changeset) do
        {:ok, tab} ->      conn
        |> put_flash(:info, "Tab updateded successfully.")
        |> redirect(to: tab_path(conn, :show, tab.name))
      end
    end
  end
  