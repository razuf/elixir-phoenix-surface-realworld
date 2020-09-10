defmodule RealWorldWeb.MainLiveTest do
  use ExUnit.Case, async: true

  use RealWorldWeb.ConnCase

  import Phoenix.LiveViewTest
  alias RealWorld.Datastore

  @valid_bio "Ich bin ein Berliner!"
  @valid_image "https://joeschmoe.io/api/v1/jack"

  @valid_login_attrs %{
    "email" => "user#{abs(System.unique_integer())}@example.com",
    "password" => "helloworld!",
    "username" => "JackThePirate"
  }
  @invalid_login_attrs %{
    "email" => "not_an_email",
    "password" => "toshort",
    "username" => nil
  }
  @session_id Ecto.UUID.generate()

  defp fixture(conn, :user_login) do
    conn =
      conn
      |> put_session(:session_id, @session_id)

    {:ok, _current_user} = Datastore.login(@valid_login_attrs, @session_id)

    conn
  end

  defp init_standard_session(init) do
    conn =
      init.conn
      |> Map.replace!(:secret_key_base, RealWorldWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{conn: conn}
  end

  defp init_user_signed_in_session(init) do
    conn =
      init.conn
      |> Map.replace!(:secret_key_base, RealWorldWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})
      |> fixture(:user_login)

    %{conn: conn}
  end

  describe "require_authenticated_user" do
    setup [:init_standard_session]

    test "shows main page information", %{conn: conn} do
      {:ok, live, _} = live(conn, "/")
      rendered = render(live) |> clean_html()
      assert rendered =~ "conduit"

      assert rendered =~
               ~s| Home |
    end

    test "redirects when require_authenticated_user", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/login"}}} == live(conn, "/settings")
      assert {:error, {:redirect, %{to: "/login"}}} == live(conn, "/editor")
      assert {:error, {:redirect, %{to: "/login"}}} == live(conn, "/editor/example_slug")
      assert {:error, {:redirect, %{to: "/login"}}} == live(conn, "/logout")
    end
  end

  describe "redirect_if_user_is_authenticated" do
    setup [:init_user_signed_in_session]

    test "redirects when redirect_if_user_is_authenticated", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} == live(conn, "/login")
      assert {:error, {:redirect, %{to: "/"}}} == live(conn, "/register")
    end
  end

  describe "click Sign in" do
    setup [:init_standard_session]

    test "click Sign in from home", %{conn: conn} do
      {:ok, live, html} = live(conn, "/login")

      assert html =~
               ~s|href=\"/register\"|

      assert live
             |> element("a", "Sign up")
             |> render_click() =~
               ~s|href=\"/register\"|
    end
  end

  defp clean_html(html) do
    html
    |> String.replace(~r/\n+/, "")
    |> String.replace(~r/\s+/, " ")
  end
end
