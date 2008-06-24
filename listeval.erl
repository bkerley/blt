-module (listeval).
-import (gdict, [lookup/1]).
-export ([listeval/1]).

listeval({list, List}) ->
	[Car|Cdr] = List,
	Function = lookup(Car),
	Filtered = recurse(Cdr, []),
	(Function)(Filtered).

recurse([], Accum) -> lists:reverse(Accum);

recurse([{list, L}|Rest], Accum) ->
	recurse(Rest, [listeval({list, L})|Accum]);

recurse([Nonlist|Rest], Accum) -> recurse(Rest, [Nonlist|Accum]).