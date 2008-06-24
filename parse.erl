-module (parse).
-export ([parse/1]).

parse (Line) when is_binary(Line) ->
	parse(binary_to_list(Line));
parse (Line) when is_list(Line)->
	[List] = recurparse(Line, [], []),
	List.

% recurparse (Remain, Context, Word, Accum)
recurparse([], [], Accum) ->
	Accum;
	
recurparse([$(|Rest], [First|Cdr], Accum) ->
	Word = try_integerize([First|Cdr]),
	{Inner, Postparse} = recurparse(Rest, [], []),
	recurparse(Postparse, [], [{list, Inner}, Word|Accum]);
recurparse([$(|Rest], [], Accum) ->
	{Inner, Postparse} = recurparse(Rest, [], []),
	recurparse(Postparse, [], [{list, Inner}|Accum]);

recurparse([$)|Rest], [First|Cdr], Accum) ->
	Word = try_integerize([First|Cdr]),
	{lists:reverse([Word|Accum]), Rest};
recurparse([$)|Rest], [], Accum) ->
	{lists:reverse(Accum), Rest};

recurparse([WS|Rest], [], Accum) when WS =< 32 ->
	recurparse(Rest, [], Accum);
recurparse([WS|Rest], [First|Cdr], Accum) when WS =< 32 ->
	Word = try_integerize([First|Cdr]),
	recurparse(Rest, [], [Word|Accum]);

recurparse([Char|Rest], Curword, Accum) ->
	recurparse(Rest, [Char|Curword], Accum).

try_integerize(Etadidnac) ->
	Candidate = lists:reverse(Etadidnac),
	try
		{number, list_to_integer(Candidate)}
	catch
		error:_ ->
			{atom, Candidate}
	end.
