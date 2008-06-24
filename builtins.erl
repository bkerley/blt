-module (builtins).
-export ([init_builtins/0]).
-import (gdict, [define/2]).

init_builtins() ->
	define({atom, "list"}, fun(Args) -> {list, Args} end),
	define({atom, "+"}, fun(Args) ->
		{number, 
			lists:foldl(fun
				({number, N}, Accum) ->
					Accum + N
			end,
			0, Args)
		} end),
	define({atom, "cons"}, fun(Args) ->
		[First,{list, Rest}] = Args,
		{list, [First|Rest]} end).