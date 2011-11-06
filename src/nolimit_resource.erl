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
  {['GET', 'HEAD', 'POST'], RD, Ctx}.

content_types_provided(RD, Ctx) ->
  {[{"application/json", to_json}], RD, Ctx}.

finish_request(RD, Ctx) ->
  bitcask:close(Ctx#context.bc).

to_json(RD, Ctx) ->
  case wrq:req_qs(RD) of
    [{"key", Key}] -> single_get(Key, RD, Ctx);
    [{"keys", RawKeys}] -> multi_get(RawKeys, RD, Ctx)
  end.

single_get(Key, RD, Ctx) ->
  Bitcask = Ctx#context.bc,
  Result = nolimit_ttl:get(Bitcask, Key),
  case Result of
    not_found -> {"not found", RD, Ctx};
    {ok, Value} -> {Value, RD, Ctx};
    true -> {"error", RD, Ctx}
  end.

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

