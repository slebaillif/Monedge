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
    put "/accounts/upload_file", AccountController, :upload_file
    get "/accounts/:id/uploaded", AccountController, :uploaded
    resources "/accounts", AccountController, only: [:index, :show, :create, :new]
    resources "/categories", CategoryController
    resources "/transactions", TransactionController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Monedge do
  #   pipe_through :api
  # end
end
