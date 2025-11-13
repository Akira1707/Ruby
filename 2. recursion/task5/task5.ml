open Sys
open Printf

(* Type to represent a file or directory *)
type node =
  | File of string
  | Dir of string * node list

(* Convert a node to JSON string with indentation *)
let rec to_json ?(indent=0) node =
  let pad = String.make indent ' ' in
  match node with
  | File name ->
      sprintf "%s{\"type\": \"file\", \"name\": \"%s\"}" pad name
  | Dir (name, children) ->
      let child_json = children
        |> List.map (to_json ~indent:(indent+4))
        |> String.concat ",\n"
      in
      sprintf "%s{\n%s    \"type\": \"dir\",\n%s    \"name\": \"%s\",\n%s    \"children\": [\n%s\n%s    ]\n%s}"
        pad pad pad name pad child_json pad pad

(* Recursively build the directory tree *)
let rec build_tree path =
  if Sys.is_directory path then
    let entries = Sys.readdir path |> Array.to_list |> List.map (Filename.concat path) in
    let children = List.map build_tree entries in
    Dir (Filename.basename path, children)
  else
    File (Filename.basename path)

(* Main function *)
let () =
  let path =
    if Array.length Sys.argv < 2 then (
      Printf.printf "Usage: ./task5 <directory>\n";
      exit 1
    ) else
      Sys.argv.(1)
  in
  let tree = build_tree path in
  let json = to_json tree in
  let out_file = "dir_tree.json" in
  let oc = open_out out_file in
  output_string oc json;
  close_out oc;
  Printf.printf "Directory tree saved to %s\n" out_file
