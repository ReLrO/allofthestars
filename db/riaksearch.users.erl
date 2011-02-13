
%% Schema for 'users'

{
    schema,
    [
        {version, "1.1"},
        {n_val, 3},
        {default_field, "content"},
        {analyzer_factory, {erlang, text_analyzers, standard_analyzer_factory}}
    ],
    [
        %% Field names ending in "_at" are indexed as dates
        %% _at is a ruby convention
        {dynamic_field, [
            {name, "*_at"},
            {type, date},
            {analyzer_factory, {erlang, text_analyzers, noop_analyzer_factory}}
        ]},

        {field, [
          {name, "cluster_id"},
          {required, true},
          {analyzer_factory, {erlang, text_analyzers,
              noop_analyzer_factory}}
        ]},

        {field, [
          {name, "content"},
          {required, true}
        ]},

        {field, [
          {name, "type"},
          {required, true},
          {analyzer_factory, {erlang, text_analyzers,
              noop_analyzer_factory}}
        ]},

        {field, [
          {name, "url"},
          {required, true},
          {analyzer_factory, {erlang, text_analyzers,
              noop_analyzer_factory}}
        ]},

        {dynamic_field, [
          {name, "custom_*"},
          {analyzer_factory, {erlang, text_analyzers,
              noop_analyzer_factory}}
        ]}
    ]
}.

