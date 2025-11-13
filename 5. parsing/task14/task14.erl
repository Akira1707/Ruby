-module(task14).
-export([run/0]).

run() ->
    InputFile = "contacts.txt",
    OutputFile = "contact.json",

    %% Read all lines from file
    {ok, Binary} = file:read_file(InputFile),
    Lines = string:split(binary_to_list(Binary), "\n", all),

    %% Determine number of workers
    NumWorkers = 4,
    ChunkSize = (length(Lines) + NumWorkers - 1) div NumWorkers,
    Chunks = chunk(Lines, ChunkSize),

    %% Spawn worker processes
    Parent = self(),
    [spawn(fun() -> worker(Chunk, Parent) end) || Chunk <- Chunks],

    %% Collect results from all workers
    Results = collect_results([], length(Chunks)),

    %% Merge emails and phones
    Emails = lists:usort([E || {emails, Es} <- Results, E <- Es]),
    Phones = lists:usort([P || {phones, Ps} <- Results, P <- Ps]),

    %% Convert to JSON
    Json = format_json(Emails, Phones),

    %% Write JSON to file
    ok = file:write_file(OutputFile, list_to_binary(Json)),
    io:format("Extraction complete. Results saved to ~s~n", [OutputFile]).

%% Worker: process a chunk of lines
worker(Lines, Parent) ->
    Emails = [E || Line <- Lines, E <- extract_emails(Line)],
    Phones = [P || Line <- Lines, P <- extract_phones(Line)],
    Parent ! {self(), {emails, Emails, phones, Phones}}.

%% Collect results from workers
collect_results(Acc, 0) -> Acc;
collect_results(Acc, N) ->
    receive
        {_, {emails, Es, phones, Ps}} ->
            collect_results([{emails, Es, phones, Ps} | Acc], N - 1)
    end.

%% Chunk list into sublists
chunk([], _) -> [];
chunk(List, N) when length(List) =< N -> [List];
chunk(List, N) ->
    {Chunk, Rest} = lists:split(N, List),
    [Chunk | chunk(Rest, N)].

%% Extract emails using regex
extract_emails(Line) ->
    Regex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
    case re:run(Line, Regex, [global, {capture, [0]}]) of
        nomatch -> [];
        {match, Matches} -> Matches
    end.

%% Extract phone numbers using regex
extract_phones(Line) ->
    Regex = "(\\+?[0-9]{1,3}[- ]?)?(\\([0-9]{1,4}\\)|[0-9]{1,4})[- ]?[0-9]{1,4}[- ]?[0-9]{1,9}",
    case re:run(Line, Regex, [global, {capture, [0]}]) of
        nomatch -> [];
        {match, Matches} -> Matches
    end.

%% Format JSON string
format_json(Emails, Phones) ->
    EmailStr = ["\"" ++ E ++ "\"" || E <- Emails],
    PhoneStr = ["\"" ++ P ++ "\"" || P <- Phones],
    "{\n"++
    "  \"emails\": [" ++ string:join(EmailStr, ", ") ++ "],\n"++
    "  \"phones\": [" ++ string:join(PhoneStr, ", ") ++ "]\n"++
    "}\n".
