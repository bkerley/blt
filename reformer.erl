-module (reformer).
-export ([reform/1]).

reform(List) ->
	lists:flatten(do_reform([List], [])).

do_reform([], Acc) -> lists:reverse(Acc);
do_reform([{list, Sublist}|Rest], Acc) ->
	ReformedSublist = do_reform(Sublist, []),
	NewAcc = [io_lib:format("( ~s)", [ReformedSublist])|Acc],
	do_reform(Rest, NewAcc);
do_reform([{atom, Atom}|Rest], Acc) ->
	do_reform(Rest, [io_lib:format("~s ", [Atom])|Acc]);
do_reform([{number, Number}|Rest], Acc) ->
	do_reform(Rest, [io_lib:format("~w ", [Number])|Acc]).