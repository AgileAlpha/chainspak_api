defmodule ChainsparkApiWeb.SessionView do
  use ChainsparkApiWeb, :view

  def render("create.json", %{ jwt: jwt }) do
    %{ jwt: jwt }
  end
end
