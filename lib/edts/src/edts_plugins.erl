%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @doc utility library for edts.
%%% @end
%%% @author Thomas Järvstrand <tjarvstrand@gmail.com>
%%% @copyright
%%% Copyright 2013 Thomas Järvstrand <tjarvstrand@gmail.com>
%%%
%%% This file is part of EDTS.
%%%
%%% EDTS is free software: you can redistribute it and/or modify
%%% it under the terms of the GNU Lesser General Public License as published by
%%% the Free Software Foundation, either version 3 of the License, or
%%% (at your option) any later version.
%%%
%%% EDTS is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU Lesser General Public License for more details.
%%%
%%% You should have received a copy of the GNU Lesser General Public License
%%% along with EDTS. If not, see <http://www.gnu.org/licenses/>.
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%_* Module declaration =======================================================
-module(edts_plugins).

%%%_* Includes =================================================================
%%%_* Exports ==================================================================

-export([dirs/0,
         names/0,
         specs/0,
         to_ret_str/1,
         to_ret_str/3
        ]).

%% Callbacks
-export([edts_server_services/1,
         event_formatters/1,
         project_node_modules/1,
         project_node_services/1]).

%%%_* Defines ==================================================================

%%%_* Types ====================================================================

-type argument() :: {Name :: atom(), Type :: atom()}.

-type function_name() :: atom().

%%%_* Behaviour callbacks ======================================================

-callback edts_server_services() -> [].

-callback event_formatters() -> [{edts_debug, edts_events_debug}].

-callback project_node_modules() -> [module()].

-callback project_node_services() -> [].

-callback spec(function_name(), arity()) -> [argument()].

%%%_* API ======================================================================

dirs() ->
  case application:get_env(edts, plugin_dir) of
    undefined -> [];
    {ok, Dir} ->
      AbsDir = filename:absname(Dir),
      PluginDirs = filelib:wildcard(filename:join(AbsDir, "*")),
      [PluginDir || PluginDir <- PluginDirs,
                    filelib:is_dir(PluginDir),
                    "edts" /= filename:basename(PluginDir)]
  end.

names() ->
  [Name || Dir <- dirs(),
           edts /= (Name = list_to_atom(filename:basename(Dir)))].


specs() ->
  lists:map(fun do_spec/1, dirs()).

to_ret_str(Term) ->
  list_to_binary(lists:flatten(io_lib:format("~p", [Term]))).

to_ret_str(Term, Indent, MaxCol) ->
  RecF = fun(_A, _N) -> no end,
  Str = lists:flatten(io_lib_pretty:print(Term, Indent, MaxCol, -1, -1, RecF)),
  list_to_binary(Str).


%% Callbacks
edts_server_services(Plugin) ->
  Plugin:edts_server_services().

event_formatters(Plugin) ->
  Plugin:event_formatters().

project_node_modules(Plugin) ->
  Plugin:project_node_modules().

project_node_services(Plugin) ->
  Plugin:project_node_services().


%%%_* Internal functions =======================================================

do_spec(Dir) ->
  [AppFile] = filelib:wildcard(filename:join([Dir, "src", "*.app.src"])),
  {ok, [AppSpec]} = file:consult(AppFile),
  AppSpec.

%%%_* Unit tests ===============================================================

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:

