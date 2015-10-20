defmodule PearProgramming.RoomChannel do
  use Phoenix.Channel
  alias PearProgamming.SharedCodeServer
  require Logger

  def join("rooms:lobby", message, socket) do
    IO.puts SharedCodeServer.write_bacon()
    Process.flag(:trap_exit, true)
    send(self, {:after_join, message})
    
    {:ok, socket}
  end

  def join("rooms:" <> _private_subtopic, _message, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"]}
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end
  
  def handle_info(:ping, socket) do
    push socket, "new:msg", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast! socket, "new:msg", %{user: msg["user"], body: msg["body"]}
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end

  def handle_out("user_joined", msg, socket) do
    if User.ignoring?(socket.assigns[:user], msg.user_id) do
      {:noreply, socket}
    else
      push socket, "user_joined", msg
      {:noreply, socket}
    end
  end
  
end
