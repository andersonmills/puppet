require 'puppet/util/methodhelper'
require 'puppet/module_tool'
require 'puppet/network/format_support'
require 'uri'

module Puppet::ModuleTool

  # This class provides a data structure representing a module's metadata.
  # @api private
  class Metadata
    include Puppet::Network::FormatSupport

    def initialize
      @data = {
        'name'         => nil,
        'version'      => nil,
        'author'       => 'UNKNOWN',
        'summary'      => 'UNKNOWN',
        'license'      => 'Apache License, Version 2.0',
        'source'       => 'UNKNOWN',
        'dependencies' => []
      }
    end

    def module_name
      @module_name
    end

    # Returns a filesystem-friendly version of this module name.
    def dashed_name
      @data['name'].tr('/', '-') if @data['name']
    end

    # Returns a string that uniquely represents this version of this module.
    def release_name
      return nil unless @data['name'] && @data['version']
      [ dashed_name, @data['version'] ].join('-')
    end

    # Merges the current set of metadata with another metadata hash.  This
    # method also handles the validation of module names and versions, in an
    # effort to be proactive about module publishing constraints.
    def update(data)
      data['author'] ||= @data['author'] unless @data['author'] == 'UNKNOWN'

      process_name(data) if data['name']
      process_version(data) if data['version']
      process_source(data) if data['source']

      @data.merge!(data)
      return self
    end

    # Returns a hash of the module's metadata.  Used by Puppet's automated
    # serialization routines.
    #
    # @see Puppet::Network::FormatSupport#to_data_hash
    def to_hash
      @data
    end
    alias :to_data_hash :to_hash

    def method_missing(name, *args)
      return @data[name.to_s] if @data.key? name.to_s
      super
    end

    private

    def process_name(data)
      validate_name(data['name'])
      author, @module_name = data['name'].split(/[-\/]/, 2)
      # data['source'] = "https://github.com/" + URI.parse(data['name']).to_s
      data['author'] ||= author
    end

    def process_version(data)
      validate_version(data['version'])
    end

    def process_source(data)
      source_uri = URI.parse(data['source'])

      #if source is github, then can set project_page and issues_url 
      if source_uri.host =~ /^(www\.)?github\.com$/
        source_uri.scheme = 'https'
        source_uri.path.sub!(/\.git$/, '')
        data['project_page'] = source_uri.to_s
        data['issues_url'] = source_uri.to_s.sub(/\/$/, '') + '/issues'
      end

    rescue URI::Error
      return
    end

    # Validates that the given module name is both namespaced and well-formed.
    def validate_name(name)
      return if name =~ /\A[a-z0-9]+[-\/][a-z][a-z0-9_]*\Z/i

      err = if name =~ /[-\/]/
        namespace, modname = name.split(/[-\/]/, 2)
        if modname =~ /^[a-z][a-z0-9_]*$/i
          "the namespace contains non-alphanumeric characters"
        elsif modname =~ /^[a-z]/i
          "the module name contains non-alphanumeric (or underscore) characters"
        else
          "the module name must begin with a letter"
        end
      else
        "the field must be a namespaced module name"
      end

      raise ArgumentError, "Invalid 'name' field in metadata.json: #{err}"
    end

    # Validates that the version string can be parsed as per SemVer.
    def validate_version(version)
      return if SemVer.valid?(version)

      err = "version string cannot be parsed as a valid Semantic Version"
      raise ArgumentError, "Invalid 'version' field in metadata.json: #{err}"
    end
  end
end

