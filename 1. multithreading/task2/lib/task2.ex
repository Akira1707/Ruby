defmodule FileCounter do
  # Main function: counts files and lines per file extension in a directory
  def count_files(dir) do
    dir
    |> Path.expand()
    |> do_count()
    |> Enum.into(%{})
  end

  # Recursive function to handle directories and files
  defp do_count(path) do
    cond do
      File.dir?(path) ->
        # If it's a directory, process each entry concurrently
        path
        |> File.ls!()
        |> Enum.map(fn entry -> spawn_count(Path.join(path, entry)) end)
        |> Enum.map(&receive_count/1)
        |> Enum.reduce(%{}, &merge_maps/2)

      File.regular?(path) ->
        # If it's a regular file, count its lines
        ext = Path.extname(path)
        lines = File.read!(path) |> String.split("\n") |> length()
        %{ext => %{files: 1, lines: lines}}

      true ->
        # If not a file or directory, return empty map
        %{}
    end
  end

  # Spawn a process to count a subdirectory or file concurrently
  defp spawn_count(path) do
    parent = self()
    pid = spawn(fn -> send(parent, {self(), do_count(path)}) end)
    pid
  end

  # Receive the result from the spawned process
  defp receive_count(pid) do
    receive do
      {^pid, result} -> result
    end
  end

  # Merge two maps by summing the number of files and lines
  defp merge_maps(a, b) do
    Map.merge(a, b, fn _key, val1, val2 ->
      %{
        files: (val1[:files] || 0) + (val2[:files] || 0),
        lines: (val1[:lines] || 0) + (val2[:lines] || 0)
      }
    end)
  end
end

# ---------------- Entry point ----------------

if length(System.argv()) < 1 do
  IO.puts("Usage: mix run lib/task2.ex <input_file>")
  System.halt(1)
end

input_file = List.first(System.argv())

# Read the target directory from the input file
dir =
  input_file
  |> File.read!()
  |> String.trim()

# Count files and lines
result = FileCounter.count_files(dir)

# Write the result to a pretty-formatted JSON file
json = Jason.encode!(result, pretty: true)
File.write!("file_count.json", json)

IO.puts(" File counting complete. Result saved to file_count.json")
