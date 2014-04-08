# encoding: UTF-8

Puppet::Face.define(:module, '1.0.0') do
  action(:show) do
    summary "Show module information"
    description <<-HEREDOC
      THIS SHOW DOCUMENTATION NEEDS TO BE WRITTEN.
    HEREDOC
    returns "description of release from the Puppet Forge"

    arguments "<name>"

    option "--version VER", "-v VER" do
      summary "Which version to show"
    end

    examples <<-'EOT'
      WE NEED SHOW EXAMPLES!!!
    EOT

    when_invoked do |name, options|
      Puppet::ModuleTool.set_option_defaults(options)
      Puppet::Forge.new.fetch_release(name, options[:version]).data
    end

    when_rendering :console do |result, name, options|
      <<-OUTPUT
#{name}
Author: #{result['metadata']['author']}
Version: #{result['version']}
Release Date: #{result['created_at']}
Release Downloads: #{result['downloads']}
Supported: #{result['supported'] ? 'supported' : 'unsupported'}

BELOW THIS LINE NEEDS TO BE WORKED ON

Currently installed: YES/NO
Version currently installed: 0.0.0
Where the module is currently installed: /opt/puppet/module/stuff

How to Install
puppet module install #{name} --version #{result['version']}

README: 
  readme
OUTPUT
    end

  end

end
