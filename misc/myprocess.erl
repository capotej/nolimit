-module(myprocess).
-compile(export_all).

-include_lib("/Users/capotej/nolimit/deps/bitcask/include/bitcask.hrl").

start_writer() ->
    Pid = spawn_link(fun() ->
          Ref = bitcask:open("test.cask", [read_write]),
          myprocess:write_proc(Ref)
      end),
    Pid.

main() ->
  erlang:process_flag(trap_exit, true),
  Writer = start_writer(),
  Writer.
  %myprocess:wait().

wait() ->
  receive 
    {write_done} ->
      wait()
  end.


write_proc(Ref) ->
  receive
    {write, Key, Value} ->
      io:format("received msg"),
      bitcask:put(Ref, term_to_binary(Key), term_to_binary(Value)),
      %Caller ! {write_done, Key},
      myprocess:write_proc(Ref)
  end.





%32> A = myprocess:start_writer().
%<0.97.0>
%33> A ! {write, "1", "2"}.
%received msg{write,"1","2"}
%35> A ! {write, "asd1", "2casd"}.
%received msg{write,"asd1","2casd"}
%36> Bc = bitcask:open("test.cask").
%#Ref<0.0.0.398>
%37> bitcask:get(Bc, term_to_binary("asd1")).
%{ok,<<131,107,0,5,50,99,97,115,100>>}
%38> bitcask:get(Bc, term_to_binary("1")).   
%{ok,<<131,107,0,1,50>>}
%39> bitcask:get(Bc, term_to_binary("14")).
%not_found
%40> A ! {write, "another", "2casd"}.        
%received msg{write,"another","2casd"}
%41> bitcask:get(Bc, term_to_binary("another")).
%{ok,<<131,107,0,5,50,99,97,115,100>>}






