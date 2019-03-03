defmodule ChainsparkApiWeb.SessionControllerTest do
  use ChainsparkApiWeb.ConnCase
  import ChainsparkApi.Factory

  setup do
    user = insert(:user)
    conn =
      build_conn()
        |> put_req_header("content-type", "application/vnd.api+json")
        |> put_req_header("chainspark-secret", "123")

    %{user: user, conn: conn}
  end

  describe "POST /api/auth/login" do
    test "returns the jwt token with valid credentials", %{conn: conn} do
      conn = post conn, "/api/auth/login", %{session: %{email: "john.doe@example.com", password: "password12345"}}
      assert conn.status == 200
    end

    test "returns 401 with invalid password", %{ conn: conn } do
      conn = post conn, "/api/auth/login", %{session: %{email: "john.doe@example.com", password: "wrong_pass"}}
      assert conn.status == 401
    end

    test "returns 401 with invalid email", %{ conn: conn } do
      conn = post conn, "/api/auth/login", %{session: %{email: "john.doe2@example.com", password: "password12345"}}
      assert conn.status == 401
    end
  end
end
