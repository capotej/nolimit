%% @author author <author@example.com>
%% @copyright YYYY author.
%% @doc Example webmachine_resource.

-module(nolimit_resource).
-export([
    init/1, 
    process_post/2,
    allowed_methods/2,
    content_types_provided/2,
    to_json/2
  ]).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("bitcask/include/bitcask.hrl").

init(Config) -> 
  Bitcask = bitcask:open("/tmp", [read_write]),
  ets:new(my_table, [named_table, protected, set, {keypos, 1}]),
  ets:insert(my_table, {bc, Bitcask}),
  %ets:lookup(my_table, foo). -> [{bc,"Bar"}]
  {ok, Config}.

allowed_methods(RD, Ctx) ->
    {['GET', 'HEAD', 'POST'], RD, Ctx}.

content_types_provided(RD, Ctx) ->
    {[{"application/json", to_json}], RD, Ctx}.



%% hit this with
%%   curl "http://localhost:8000/?key=key"
to_json(RD, Ctx) ->
    [{"key",Key}] = wrq:req_qs(RD),
    [{bc, Bitcask}] = ets:lookup(my_table, bc),
    Result = bitcask:get(Bitcask, term_to_binary(Key)),
    %if Result =:= not_found -> {"not found", RD, Ctx};
    %  true -> {Result, RD, Ctx}
    %end.
    case Result of
      not_found -> {"not_found", RD, Ctx};
      {ok, Bin} -> {binary_to_term(Bin), RD, Ctx};
      true -> {"error", RD, Ctx}
    end.

%% hit this with
%%   curl -X POST http://localhost:8000/formjson \
%%        -d "one=two&me=pope"
process_post(RD, Ctx) ->
    [{Key,Value}] = mochiweb_util:parse_qs(wrq:req_body(RD)),
    [{bc, Bitcask}] = ets:lookup(my_table, bc),
    bitcask:put(Bitcask, term_to_binary(Key), term_to_binary(Value)),
    {true, wrq:append_to_response_body("ok", RD), Ctx}.

