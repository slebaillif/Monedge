defmodule Monedge.Router do
  use Monedge.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Monedge do
    pipe_through :browser # Use the default browser stack



    get "/", PageController, :index
    get "/accounts/:id/upload", AccountController, :upload
    put "/accounts/:id/upload_file", AccountController, :upload_file
    get "/accounts/:id/:lines/uploaded", AccountController, :uploaded
    get "/transactions/train", TransactionController, :train
    get "/transactions/unclassified", TransactionController, :unclassified
    get "/visu/d3test",VisuController, :d3test
    get "/visu/pie",VisuController, :pie
    get "/visu/bar",VisuController, :barWithDate
    post "/visu/bar",VisuController, :viewBarByCategoryAndDateRange
    get "/visu/sbar",VisuController, :sbarWithDate
    post "/visu/sbar",VisuController, :viewStackedBarByCategoryAndDateRange
    get "/transactions/:id/guess", TransactionController, :guess
    resources "/accounts", AccountController, only: [:index, :show, :create, :new]
    resources "/users", UserController, only: [:index, :show, :create, :new]
    resources "/tabs", TabController, only: [:index, :show, :create, :new]
    resources "/categories", CategoryController
    resources "/transactions", TransactionController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Monedge do
  #   pipe_through :api
  # end
end
