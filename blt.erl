-module (blt).
-export ([do/1]).
-import (parse, [parse/1]).
-import (listeval, [listeval/1]).

do (Command) ->
	Parsed = parse(Command),
	listeval(Parsed).