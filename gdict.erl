-module (gdict).
-behaviour (gen_server).
-include ("gdict.hrl").
-export ([start_link/0, init/1, terminate/2]).
-export ([lookup/1, define/2]).
-export ([handle_call/3, handle_info/2, handle_cast/2, code_change/3]).

start_link () ->
	gen_server:start_link({local, gdict}, gdict, [], []).

define(Name, Value) ->
	gen_server:call(gdict, {define, Name, Value}).

lookup(Name) ->
	{gdict, Name, Value} = gen_server:call(gdict, {lookup, Name}),
	Value.

init (_Args) ->
	ok = mnesia:start(),
	mnesia:create_table(gdict, [
		{ram_copies, [node()]},
		{attributes, record_info(fields, gdict)}]),
	{ok, ready}.

terminate (_,_) ->
	{atomic, ok} = mnesia:delete_table(gdict),
	mnesia:stop().

handle_call(ping, _, ready) ->
	{reply, pong, ready};

handle_call ({define, Name, Value}, _, ready) ->
	Record = #gdict{key = Name, value = Value},
	Writer = fun () ->
		mnesia:write(Record)
	end,
	Result = mnesia:transaction(Writer),
	{reply, Result, ready};

handle_call ({lookup, Name}, _, ready) ->
	Reader = fun () ->
		mnesia:read({gdict, Name})
	end,
	{atomic, List} = mnesia:transaction(Reader),
	case List of
		[] ->
			{reply, notfound, ready};
		[Item] ->
			{reply, Item, ready}
	end.

handle_info(_,ready) ->
	{noreply, ready}.

handle_cast(_, ready) ->
	{noreply, ready}.

code_change(_, ready, _) ->
	{ok, ready}.