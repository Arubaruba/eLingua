fun({Doc}) ->
 K = proplists:get_value(<<\"name\">>, Doc, null),
 Emit(K, {Doc})
end.