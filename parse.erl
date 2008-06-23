-module (parse).
-export ([parse/1]).

% we parse into a backwards list and then reverse it
parse (Line) when is_binary(Line) ->
	parse(binary_to_list(Line));
parse (Line) when is_list(Line)->
	Normalized = phase0(Line),
	PhaseOne = phase1(Normalized),
	PhaseTwo = phase2(PhaseOne, [], []),
	PhaseThree = phase3(PhaseTwo, []),
	PhaseThree.

phase0(Unnormalized) -> 
	lists:map(fun
		(Char) when Char =< 32 ->
			$ ;
		(Char) ->
			Char
	end, Unnormalized).

phase1(Normalized) ->
	try
		{ok, [Listified]} = listify(Normalized, []),
		Listified
	catch
		error: {badmatch, _} ->
			erlang:error(
				{parse, closed_list, "Parse error: tried to close more lists than were opened."})
	end.

listify([], List) ->
	{ok, List};

listify(ok, _) ->
	erlang:error(
		{parse, open_list,"Parse error: ran into the end of line with an open list."});

listify([$(|Remains], List) ->
	{Postlist, InnerList} = listify(Remains, []),
	listify(Postlist, [InnerList|List]);

listify([$)|Remains], List) ->
	{Remains, lists:reverse(List)};

listify([Current|Remains], List) ->
	listify(Remains, [Current|List]).

phase2([], [], List) ->
	lists:reverse(List);

phase2([], Atom, List) ->
	lists:reverse([lists:reverse(Atom)|List]);

phase2([$ |Remains], Atom, List) ->
	phase2(Remains, [], [lists:reverse(Atom)|List]);

phase2([Sublist|Remains], [], List) when is_list(Sublist) ->
	phase2(Remains, [], [phase2(Sublist, [], []) | List ]);
	
phase2([Sublist|Remains], Atom, List) when is_list(Sublist) ->
	phase2(Remains, [], [phase2(Sublist, [], []), lists:reverse(Atom) | List ]);

phase2([Char|Remains], Atom, List) when is_integer(Char) ->
	phase2(Remains, [Char|Atom], List).

phase3([], List) ->
	{sublist, lists:reverse(List)};

phase3([Sample|Remains], _) when is_integer(Sample) ->
	try_integerize([Sample|Remains]);

phase3([Sample|Remains], List) when is_list(Sample) ->
	Sublist = phase3(Sample, []),
	Recurlist = [Sublist|List],
	phase3(Remains, Recurlist).

try_integerize(Candidate) ->
	try
		{number, list_to_integer(Candidate)}
	catch
		error:_ ->
			{atom, Candidate}
	end.