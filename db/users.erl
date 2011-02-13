
%% Schema for 'users'

{
    schema,
    [
        {version, "1.1"},
        {n_val, 3},
        {default_field, "name"},
        {analyzer_factory, {erlang, text_analyzers, standard_analyzer_factory}}
    ],
    [
        {field, [
          {name, "name"},
          {required, true},
          {analyzer_factory, {erlang, text_analyzers,
              noop_analyzer_factory}}
        ]},

        {field, [
          {name, "email"},
          {required, true},
          {analyzer_factory, {erlang, text_analyzers,
              noop_analyzer_factory}}
        ]}
    ]
}.

