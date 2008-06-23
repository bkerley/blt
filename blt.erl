-module (blt).
-export ([do/1]).
-import (parse, [parse/1]).

do (Command) ->
	Parsed = parse(Command),
	Parsed.