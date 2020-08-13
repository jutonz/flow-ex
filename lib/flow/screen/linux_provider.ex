defmodule Flow.Screen.LinuxProvider do
  def sleep do
    System.cmd("xset", ~w[dpms force on], env: [{"DISPLAY", ":0"}])
  end

  def wake do
    System.cmd("xset", ~w[dpms force on], env: [{"DISPLAY", ":0"}])
  end
end
