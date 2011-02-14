-module(gravastar_analyzers).
-export([iso8601_analyzer_factory/2]).

-define(NUMBER(C),(C >= $0 andalso C =< $9)).

%% Tokenizes an ISO8601 date like '2011-02-14T17:23:06Z' to just one big
%% string: "20110214172306"
iso8601_analyzer_factory(Text, _) ->
  [WithoutZ]   = string:tokens(Text, "Z"),
  [Date, Time] = string:tokens(WithoutZ, "T"),
  [Y, M, D]    = string:tokens(Date, "-"),
  [H, MM, S]   = string:tokens(Time, ":"),
  {ok, [string:join([Y, M, D, H, MM, S], "")]}.
