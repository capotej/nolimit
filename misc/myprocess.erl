-module(myprocess).
-compile(export_all).

-include_lib("/Users/capotej/nolimit/deps/bitcask/include/bitcask.hrl").

start() ->
  spawn(myprocess, start_bitcask, []).


start_bitcask() ->
  receive
    {write, Key, Value} ->
      Bitcask = bitcask:open("/tmp/lol", [read_write]),
      bitcask:put(Bitcask, term_to_binary(Key), term_to_binary(Value)),
      bitcask:close(Bitcask),
      start_bitcask();
    _ ->
      start_bitcask()
  end.
