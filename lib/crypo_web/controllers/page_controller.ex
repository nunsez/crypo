defmodule CrypoWeb.PageController do
  use CrypoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
