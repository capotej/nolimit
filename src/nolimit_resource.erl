%% @author Julio Capote <jcapote@gmail.com>
%% @copyright 2011 Julio Capote.
%% @doc No Limit Resource

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

start_bitcask() ->
  Bitcask = bitcask:open("/tmp", [read_write]),
  receive 
    {write, Key, Value} ->
      bitcask:put(Bitcask, term_to_binary(Key), term_to_binary(Value))
  end.

init(Config) -> 
  Bpid = spawn(nolimit_resource, start_bitcask, []).
  ets:new(my_table, [named_table, protected, set, {keypos, 1}]),
  ets:insert(my_table, {bc, Bpid}),
  %ets:lookup(my_table, foo). -> [{bc,"Bar"}]
  {ok, Config}.

allowed_methods(RD, Ctx) ->
    {['GET', 'HEAD', 'POST'], RD, Ctx}.

content_types_provided(RD, Ctx) ->
    {[{"application/json", to_json}], RD, Ctx}.

to_json(RD, Ctx) ->
    [{"key",Key}] = wrq:req_qs(RD),
    [{bc, Bitcask}] = ets:lookup(my_table, bc),
    Result = bitcask:get(Bitcask, term_to_binary(Key)),
    case Result of
      not_found -> {"not_found", RD, Ctx};
      {ok, Bin} -> {binary_to_term(Bin), RD, Ctx};
      true -> {"error", RD, Ctx}
    end.

process_post(RD, Ctx) ->
    [{Key,Value}] = mochiweb_util:parse_qs(wrq:req_body(RD)),
    [{bc, Bitcask}] = ets:lookup(my_table, bc),
    Bitcask ! {write, Key, VAlue}
    %bitcask:put(Bitcask, term_to_binary(Key), term_to_binary(Value)),
    {true, wrq:append_to_response_body("ok", RD), Ctx}.

