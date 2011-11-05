%% @author Julio Capote <jcapote@gmail.com>
%% @copyright 2011 Julio Capote.
%% @doc No Limit Resource

-module(nolimit_resource).
-compile(export_all).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("bitcask/include/bitcask.hrl").

init(Config) -> 
  {ok, Config}.

allowed_methods(RD, Ctx) ->
    {['GET', 'HEAD', 'POST'], RD, Ctx}.

content_types_provided(RD, Ctx) ->
    {[{"application/json", to_json}], RD, Ctx}.

to_json(RD, Ctx) ->
    [{"key",Key}] = wrq:req_qs(RD),
    Bitcask = bitcask:open("nolimit.cask"),
    Result = bitcask:get(Bitcask, term_to_binary(Key)),
    bitcask:close(Bitcask),
    case Result of
      not_found -> {"not found", RD, Ctx};
      {ok, Bin} -> {binary_to_term(Bin), RD, Ctx};
      true -> {"error", RD, Ctx}
    end.

process_post(RD, Ctx) ->
    [{Key,Value}] = mochiweb_util:parse_qs(wrq:req_body(RD)),
    writer ! {write, Key, Value},
    {true, wrq:append_to_response_body("ok", RD), Ctx}.

