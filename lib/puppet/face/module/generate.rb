Puppet::Face.define(:module, '1.0.0') do
  action(:generate) do
    summary "Generate boilerplate for a new module."
    description <<-EOT
      Generates boilerplate for a new module by creating the directory
      structure and files recommended for the Puppet community's best practices.

      A module may need additional directories beyond this boilerplate
      if it provides plugins, files, or templates.
    EOT

    returns "Array of Pathname objects representing paths of generated files."

    examples <<-EOT
      Generate a new module in the current directory:

      $ puppet module generate puppetlabs-ssh
      notice: Generating module at /Users/kelseyhightower/puppetlabs-ssh
      puppetlabs-ssh
      puppetlabs-ssh/Modulefile
      puppetlabs-ssh/README
      puppetlabs-ssh/manifests
      puppetlabs-ssh/manifests/init.pp
      puppetlabs-ssh/spec
      puppetlabs-ssh/spec/spec_helper.rb
      puppetlabs-ssh/tests
      puppetlabs-ssh/tests/init.pp
    EOT

    arguments "<name>"

    when_invoked do |name, options|
      "This format is not supported by this action."
    end

    when_rendering :console do |_, name, options|
      Puppet::ModuleTool.set_option_defaults options
      Puppet::ModuleTool::Generate.generate(name, options).join("\n")
    end
  end
end

module Puppet::ModuleTool::Generate
  module_function

  def generate(name, options)
    begin
      metadata = Puppet::ModuleTool::Metadata.new.update(
        'name' => name,
        'version' => '0.0.1',
        'dependencies' => [
          { :name => 'puppetlabs-stdlib', :version_range => '>= 1.0.0' }
        ]
      )

      interview(metadata)

      # These are used in the generation of the metadata.json file t
      # simulate an ordered hash.  In particular, the keys listed below are
      # promoted to the top of the serialized hash for human-friendliness.
      #
      # This particularly works around the lack of ordered hashes in 1.8.7.
      hash = metadata.to_hash
      remaining_keys = hash.keys - %w[ name version author summary license source ]
    rescue ArgumentError
      msg = "Could not generate directory #{full_module_name.inspect}, you must specify a dash-separated username and module name."
      raise $!, msg, $!.backtrace
    end

    STDERR.puts

    skeleton_path = Pathname(Puppet.settings[:module_skeleton_dir])
    skeleton_path = Pathname(__FILE__).dirname + '../../module_tool/skeleton/templates/generator' unless skeleton_path.directory?

    destination = Pathname.new(metadata.dashed_name)

    if destination.exist?
      raise ArgumentError, "#{destination} already exists."
    end

    Puppet.notice "Generating module at #{Dir.pwd}/#{metadata.dashed_name}"

    FileUtils.cp_r skeleton_path, destination

    Dir[destination + '**/*.erb'].each do |erb|
      path = Pathname.new(erb)
      target = path.parent + path.basename('.erb')

      content = ERB.new(path.read).result(binding)
      target.open('w') { |f| f.write(content) }
      path.unlink
    end

    return Dir[destination + '**/*']
  end

  def interview(metadata)
    puts "We need to create a metadata.json file for your module.  Please answer the"
    puts "following questions; if the question is not applicable to your module, feel free"
    puts "to leave it blank."
    puts
    puts "Puppet uses Semantic Versioning (semver.org) to version modules."
    puts "What version is your module?  [#{metadata.to_hash['version']}]"
    metadata.update ask('version', metadata.to_hash['version'])
    puts
    puts "What is the name of this module's author (who gets the credit/blame for this"
    puts "module)?  [#{metadata.to_hash['author']}]"
    metadata.update ask('author', metadata.to_hash['author'])
    puts
    puts "What license does your module code fall under?  [#{metadata.to_hash['license']}]"
    metadata.update ask('license', metadata.to_hash['license'])
    puts
    puts "How would you describe your module in a single sentence?"
    metadata.update ask('summary', metadata.to_hash['summary'])
    puts
    puts "Where is your module's source code repository?"
    metadata.update ask('source', metadata.to_hash['source'])
    puts
    puts "Where can others go to learn more about your module?"
    metadata.update ask('project_page', metadata.to_hash['project_page'])
    puts
    puts "Where can others go to file issues about your module?"
    metadata.update ask('issues_url', metadata.to_hash['issues_url'])
  end

  def ask(key, default = nil)
    print '--> '
    response = STDIN.gets.chomp
    response = default if response == ''
    return { key => response }
  end
end
