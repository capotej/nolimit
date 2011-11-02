%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Callbacks for the nolimit application.

-module(nolimit_app).
-author('author <author@example.com>').

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for nolimit.
start(_Type, _StartArgs) ->
    nolimit_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for nolimit.
stop(_State) ->
    ok.
