defmodule RealWorld.Api do
  @moduledoc """
    The backend Api connection.
  """

  alias RealWorld.Datastore

  def compose_url(url) do
    System.get_env(
      "CONDUIT_BACKEND_API_URL",
      Application.fetch_env!(:real_world, :conduit_backend_api_url)
    ) <> URI.encode(url)
  end

  def headers(session_id) do
    token = Datastore.get_token_by_session_id(session_id)

    if token do
      [
        {"content-type", "application/json"},
        {"authorization", "Token " <> token}
      ]
    else
      [{"content-type", "application/json"}]
    end
  end

  def server_get(url, session_id \\ "") do
    request = Finch.build(:get, compose_url(url), headers(session_id))

    call_request(request)
  end

  def server_post(url, request_body, session_id \\ "") do
    body = request_body |> Jason.encode!()
    request = Finch.build(:post, compose_url(url), headers(session_id), body)

    call_request(request)
  end

  def server_delete(url, session_id \\ "") do
    request = Finch.build(:delete, compose_url(url), headers(session_id))

    call_request(request)
  end

  def server_put(url, request_body, session_id \\ "") do
    body = request_body |> Jason.encode!()

    request = Finch.build(:put, compose_url(url), headers(session_id), body)

    call_request(request)
  end

  defp call_request(request) do
    case Finch.request(request, MyFinch) do
      {:ok, result} ->
        case result.body do
          "{" <> rest = body ->
            body
            |> Jason.decode!()

          "" ->
            ""

          _ ->
            IO.inspect(binding(), label: "### api error - finch call")
        end

      error ->
        IO.inspect(binding(), label: "### api error - finch call")
    end
  end
end
