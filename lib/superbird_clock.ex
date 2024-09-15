defmodule SuperbirdClock do
  @moduledoc """
  Documentation for `SuperbirdClock`.
  """

  def ssh_check_pass(_provided_username, provided_password) do
    correct_password = Application.get_env(:superbird_clock, :password, "superbird")
    provided_password == to_charlist(correct_password)
  end

  def ssh_show_prompt(_peer, _username, _service) do
    {:ok, name} = :inet.gethostname()

    msg = """
    ssh superbird@#{name}.local # Use password "superbird"
    """

    {~c"Superbird", to_charlist(msg), ~c"Password: ", false}
  end
end
