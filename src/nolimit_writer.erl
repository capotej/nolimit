-module(nolimit_writer).
-compile(export_all).

-include_lib("bitcask/include/bitcask.hrl").

write_proc(Ref) ->
  receive
    {write, Key, Value} ->
      bitcask:put(Ref, term_to_binary(Key), term_to_binary(Value)),
      nolimit_writer:write_proc(Ref);
		{merge} ->
			bitcask:merge("nolimit.cask"),
			nolimit_writer:write_proc(Ref)
	end.

start_writer() ->
    Pid = spawn_link(fun() ->
          Ref = bitcask:open("nolimit.cask", [read_write]),
          nolimit_writer:write_proc(Ref)
      end),
    Pid.
