-module (gdict).
-include ("gdict.hrl").
-export ([init/0, lookup/1, define/2]).

define(Name, Value) ->
	Record = #gdict{key = Name, value = Value},
	Writer = fun () ->
		mnesia:write(Record)
	end,
	mnesia:transaction(Writer).

lookup(Name) ->
	Reader = fun () ->
		mnesia:read({gdict, Name})
	end,
	{atomic, Item} = mnesia:transaction(Reader),
	
	case Item of
		[{gdict, Name, Value}] ->
			Value;
		[] ->
			erlang:error({gdict, noproc, "Couldn't find a proc.", Name})
	end.

init () ->
	ok = mnesia:start(),
	mnesia:create_table(gdict, [
		{ram_copies, [node()]},
		{attributes, record_info(fields, gdict)}]),
	{ok, ready}.