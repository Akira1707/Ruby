(* Utility: get length of a string *)
fun strlen (s : string) = String.size s

(* Find index of first occurrence of a char starting from pos i. *)
fun find_char_from (s: string, ch: char, i: int) =
    let
        fun loop j =
            if j >= strlen s then NONE
            else if String.sub(s, j) = ch then SOME j
            else loop (j+1)
    in
        loop i
    end

(* Extract first token of a line (up to first space) *)
fun first_token (s: string) =
    case find_char_from(s, #" ", 0) of
         NONE => s
       | SOME idx => String.substring(s, 0, idx)

(* Trim whitespace *)
fun is_space c = (c = #" " orelse c = #"\n" orelse c = #"\r" orelse c = #"\t")

fun ltrim s =
    let
        fun lpos i =
            if i >= strlen s then strlen s
            else if is_space (String.sub(s,i)) then lpos (i+1)
            else i
        val p = lpos 0
    in
        if p = 0 then s
        else if p >= strlen s then ""
        else String.substring(s, p, strlen s - p)
    end

fun rtrim s =
    let
        fun rpos i =
            if i < 0 then ~1
            else if is_space (String.sub(s,i)) then rpos (i-1)
            else i
        val p = rpos (strlen s - 1)
    in
        if p < 0 then ""
        else String.substring(s, 0, p+1)
    end

fun trim s = rtrim (ltrim s)

(* Validate IPv4-like token *)
fun is_digits s =
    let
        fun loop i =
            if i >= strlen s then true
            else if Char.isDigit (String.sub(s,i)) then loop (i+1)
            else false
    in
        (strlen s > 0) andalso loop 0
    end

fun split_on_dot s =
    let
        fun collect (pos, acc, start) =
            if pos = strlen s then
                let val last = String.substring(s,start,pos-start)
                in List.rev (last::acc) end
            else if String.sub(s,pos) = #"."
            then
                let val token = String.substring(s,start,pos-start)
                in collect(pos+1, token::acc, pos+1) end
            else collect(pos+1, acc, start)
    in
        if strlen s = 0 then [] else collect(0, [], 0)
    end

fun parse_uint_opt s =
    case Int.fromString s of
         NONE => NONE
       | SOME n => if n >= 0 then SOME n else NONE

fun valid_ipv4 s =
    let
        val parts = split_on_dot s
        fun validPart p =
            (is_digits p) andalso
            (case parse_uint_opt p of
                 SOME v => (v >= 0) andalso (v <= 255)
               | NONE => false)
    in
        case parts of
            [a,b,c,d] => validPart a andalso validPart b andalso validPart c andalso validPart d
          | _ => false
    end

(* Association-list counter *)
fun incr_assoc ([], key) = [(key, 1)]
  | incr_assoc ((k,v)::rest, key) =
      if k = key then (k, v+1)::rest
      else (k,v)::(incr_assoc(rest, key))

(* Fold through lines and update counts *)
fun count_ips lines =
    let
        fun process_line (line, acc) =
            let
                val tok = trim (first_token line)
            in
                if valid_ipv4 tok then incr_assoc(acc, tok) else acc
            end
    in
        List.foldl process_line [] lines
    end

(* Quicksort by count descending *)
fun qsort_by_count [] = []
  | qsort_by_count ((k,c)::xs) =
        let
            fun split ([], lo, hi) = (lo, hi)
              | split ((k2,c2)::ys, lo, hi) =
                    if c2 > c then split(ys, (k2,c2)::lo, hi)
                    else split(ys, lo, (k2,c2)::hi)
            val (lo, hi) = split(xs, [], [])
        in
            qsort_by_count lo @ [(k,c)] @ qsort_by_count hi
        end

(* Take first n items *)
fun take (0, _) = []
  | take (_, []) = []
  | take (n, x::xs) = x :: take(n-1, xs)

(* JSON escape *)
fun json_escape s =
    let
        fun esc [] acc = acc
          | esc (c::cs) acc =
              case c of
                 #"\"" => esc cs (acc ^ "\\\"")
               | #"\\" => esc cs (acc ^ "\\\\")
               | _ => esc cs (acc ^ String.implode [c])
    in esc (String.explode s) "" end

fun join_with (sep, lst) =
    case lst of
         [] => ""
       | [x] => x
       | x::xs => x ^ sep ^ join_with(sep, xs)

fun top_ips_json pairs =
    let
        fun item_to_json (ip, cnt) =
            "    {\"ip\": \"" ^ json_escape ip ^ "\", \"count\": " ^ Int.toString cnt ^ "}"
        val items = List.map item_to_json pairs
    in
        "[\n" ^ join_with(",\n", items) ^ "\n]\n"
    end

(* Analyze log file *)
fun analyze inputFile outputFile =
    let
        val inchan = TextIO.openIn inputFile
        val content = TextIO.inputAll inchan
        val _ = TextIO.closeIn inchan
        val lines = String.tokens (fn c => c = #"\n") content

        val assoc = count_ips lines
        val sorted = qsort_by_count assoc
        val top5 = take (5, sorted)
        val json = top_ips_json top5

        val out = TextIO.openOut outputFile
        val _ = TextIO.output(out, json)
        val _ = TextIO.closeOut out
    in
        ()
    end

(* Export structure *)
structure LogAnalyzer =
struct
    val analyze = analyze
end

val _ = print "LogAnalyzer loaded. Use LogAnalyzer.analyze \"access.log\" \"top_ips.json\";\n"