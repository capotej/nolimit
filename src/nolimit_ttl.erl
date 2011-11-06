-module(nolimit_ttl).

-compile(export_all).

get(Bitcask, StrKey) ->
  Key = term_to_binary(StrKey),
  Result = bitcask:get(Bitcask, Key),
  case Result of
    not_found -> 
      not_found;
    {ok, Bin} -> 
      [Value, Ttl, Time] = binary_to_term(Bin),
      Now = epoch_seconds(),
      if 
        Ttl == 0 ->
          {ok, Value};
        (Ttl + Time) < Now ->
          bitcask:delete(Bitcask, Key),
          not_found;
        true ->
          {ok, Value}
      end
  end.


epoch_seconds() ->
  calendar:datetime_to_gregorian_seconds(calendar:now_to_universal_time( now()))-719528*24*3600.


