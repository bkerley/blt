-module (parse).
-export ([parse/1]).

% we parse into a backwards list and then reverse it
parse (Line) when is_binary(Line) ->
	parse(binary_to_list(Line));
parse (Line) when is_list(Line)->
	Normalized = phase0(Line),
	{ok, PhaseOne} = phase1(Normalized, []),
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

phase1([$(|Remains], List) ->
	{Postlist, InnerList} = phase1(Remains, []),
	phase1(Postlist, [InnerList|List]);

phase1([$)|Remains], List) ->
	{Remains, lists:reverse(List)};

phase1([Current|Remains], List) ->
	phase1(Remains, [Current|List]);

phase1([], List) ->
	{ok, List}.

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