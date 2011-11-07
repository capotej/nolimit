%% @author Julio Capote <jcapote@gmail.com>
%% @copyright 2011 Julio Capote.
%% @doc No Limit Resource

-module(nolimit_resource).
-compile(export_all).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("bitcask/include/bitcask.hrl").

-record(context, {bc=undefined, value=undefined}).

init(_) -> 
  Ctx = #context{bc=bitcask:open("nolimit.cask")},
  {ok, Ctx}.

allowed_methods(RD, Ctx) ->
  {['GET', 'HEAD', 'POST', 'DELETE'], RD, Ctx}.

content_types_provided(RD, Ctx) ->
  case wrq:req_qs(RD) of
    [{"keys", _}] ->
      {[{"application/json", render}], RD, Ctx};
    _ ->
      {[{"text/plain", render}], RD, Ctx}
  end.

finish_request(RD, Ctx) ->
  bitcask:close(Ctx#context.bc),
  {true, RD, Ctx}.

resource_exists(RD, Ctx) ->
  case wrq:req_qs(RD) of
    [{"key", Key}] -> 
      Bitcask = Ctx#context.bc,
      Result = nolimit_ttl:get(Bitcask, Key),
      case Result of
        not_found -> 
          RD1 = wrq:set_resp_body(<<"not found">>, RD),
          {false, RD1, Ctx};
        {ok, Value} -> 
          Ctx1 = Ctx#context{value=Value},
          {true, RD, Ctx1};
        true -> {false, RD, Ctx}
      end;
    [{"keys",_}] -> 
      {true, RD, Ctx};
    _ ->
      {true, RD, Ctx}
  end.

render(RD, Ctx) ->
  case wrq:req_qs(RD) of
    [{"key", Key}] -> single_get(Key, RD, Ctx);
    [{"keys", RawKeys}] -> multi_get(RawKeys, RD, Ctx)
  end.

delete_resource(RD, Ctx) ->
  [{"key", Key}] = wrq:req_qs(RD),
  writer ! {delete, Key},
  {true, RD, Ctx}.

single_get(_Key, RD, Ctx) ->
  {Ctx#context.value, RD, Ctx}.

multi_get(RawKeys, RD, Ctx) ->
  Keys = string:tokens(RawKeys, ","),
  Result = {struct, nolimit_multiget:without_missing(Keys)},
  Json = binary:bin_to_list(iolist_to_binary(mochijson2:encode(Result))),
  {Json, RD, Ctx}.

process_post(RD, Ctx) ->
  case mochiweb_util:parse_qs(wrq:req_body(RD)) of
    [{Key,Value}] ->  writer ! {write, Key, Value};
    [{Key,Value}, {"ttl", Seconds}] -> writer ! {write, Key, Value, Seconds}
  end,
  {true, wrq:append_to_response_body("ok", RD), Ctx}.

