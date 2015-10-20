defmodule PearProgramming.SharedCodeServer do
  def write_bacon do
     IO.puts "bacon"
     "bacon"
  end
  
  def start_link do
      Agent.start_link(fn -> "bacon"  end, name: __MODULE__)
  end
  
  def add_code(code) do
    Agent.update(__MODULE__, fn(code) -> code end)
  end
  
  def get_code do
    Agent.get(__MODULE__, fn(code) -> code end)
  end

end