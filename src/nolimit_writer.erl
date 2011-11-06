-module(nolimit_writer).
-compile(export_all).

-include_lib("bitcask/include/bitcask.hrl").

write_proc(Ref) ->
  receive
    {write, Key, Value} ->
      bitcask:put(Ref, term_to_binary(Key), term_to_binary([Value, 0, nolimit_resource:epoch_seconds()])),
      nolimit_writer:write_proc(Ref);
    {write, Key, Value, Seconds} ->
      bitcask:put(Ref, term_to_binary(Key), term_to_binary([Value, string:to_integer(Seconds), nolimit_resource:epoch_seconds()])),
      nolimit_writer:write_proc(Ref)
  end.

start_writer() ->
    Pid = spawn_link(fun() ->
          Ref = bitcask:open("nolimit.cask", [read_write]),
          nolimit_writer:write_proc(Ref)
      end),
    Pid.
