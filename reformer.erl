-module (reformer).
-export ([reform/1]).

reform(List) ->
	lists:flatten(do_reform(List)).

do_reform([]) -> [];
do_reform({list, Sublist}) ->
	ReformedSublist = do_reform(Sublist),
	io_lib:format("( ~s)", [ReformedSublist]);
do_reform({atom, Atom}) ->
	io_lib:format("~s", [Atom]);
do_reform({number, Number}) ->
	io_lib:format("~w", [Number]);
do_reform([First|Rest]) ->
	ReformedFirst = do_reform(First),
	ReformedRest = do_reform(Rest),
	io_lib:format("~s ~s", [ReformedFirst, ReformedRest]).