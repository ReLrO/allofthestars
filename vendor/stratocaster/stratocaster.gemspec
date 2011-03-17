## This is the rakegem gemspec template. Make sure you read and understand
## all of the comments. Some sections require modification, and others can
## be deleted if you don't need them. Once you understand the contents of
## this file, feel free to delete any comments that begin with two hash marks.
## You can find comprehensive Gem::Specification documentation, at
## http://docs.rubygems.org/read/chapter/20
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  ## Leave these as is they will be modified for you by the rake gemspec task.
  ## If your rubyforge_project name is different, then edit it and comment out
  ## the sub! line in the Rakefile
  s.name              = 'stratocaster'
  s.version           = '0.0.1'
  s.date              = '2011-03-17'
  s.rubyforge_project = 'stratocaster'

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = "Short description used in Gem listings."
  s.summary     = "A system for storing and retrieving messages on timelines."
  s.description = "Long description. Maybe copied from the README."
  s.description = <<-END
    Stratocaster is a system for storing and retrieving messages on
    timelines. A message can contain any arbitrary payload. A timeline is a
    filtered stream of messages.  Complex querying is replaced in favor of
    creating multiple timelines as filters for the messages.  Stratocaster
    uses abstract adapters to persist the data, instead of being bound to
    any one type of data store.
  END

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["John Doe"]
  s.email    = 'jdoe@example.com'
  s.homepage = 'http://example.com/NAME'

  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  ## Specify any RDoc options here. You'll want to add your README and
  ## LICENSE files to the extra_rdoc_files list.
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  ## List your runtime dependencies here. Runtime dependencies are those
  ## that are needed for an end user to actually USE your code.
  #s.add_dependency('DEPNAME', [">= 1.1.0", "< 2.0.0"])

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  #s.add_development_dependency('DEVDEPNAME', [">= 1.1.0", "< 2.0.0"])

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    LICENSE
    README.md
    Rakefile
    lib/stratocaster.rb
    lib/stratocaster/adapter.rb
    lib/stratocaster/adapters/memory.rb
    lib/stratocaster/adapters/redis.rb
    lib/stratocaster/timeline.rb
    stratocaster.gemspec
    test/adapter_test.rb
    test/helper.rb
    test/stratocaster_test.rb
    test/timeline_test.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^test\/.*_test\.rb/ }
end

