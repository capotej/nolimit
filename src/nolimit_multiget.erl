-module(nolimit_multiget).
-compile(export_all).

-include_lib("bitcask/include/bitcask.hrl").

%thanks luke! http://lukego.livejournal.com/6753.html

pmap(F,List) ->
  [wait_result(Worker) || Worker <- [spawn_worker(self(),F,E) || E <- List]].

spawn_worker(Parent, F, E) ->
  erlang:spawn_monitor(fun() -> Parent ! {self(), F(E)} end).

wait_result({Pid,Ref}) ->
  receive
    {'DOWN', Ref, _, _, normal} -> receive {Pid,Result} -> Result end;
    {'DOWN', Ref, _, _, Reason} -> exit(Reason)
  end.

% include missing results
with_missing(Keys) ->
    pmap(fun(Key) -> 
        Bitcask = bitcask:open("nolimit.cask"),
        Result = case nolimit_ttl:get(Bitcask, Key) of
          {ok, Bin} -> {Key, binary:list_to_bin(Bin)};
          _ -> {Key, not_found} 
        end,
        bitcask:close(Bitcask),
        Result
    end, Keys).

% only return the results that were found
without_missing(Keys) ->
  Results = with_missing(Keys),
  lists:filter(fun(Result) -> 
      case Result of
        {_, not_found} -> false;
        _ -> true
      end
    end, Results).


