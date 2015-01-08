#require 'puppet/util/methodhelper'
require 'puppet/module_tool'
require 'puppet/network/format_support'
require 'uri'
require 'json'
#require 'set'
require 'puppet/module_tool/metadata/base_metadata'

module Puppet::ModuleTool

  # This class provides a data structure representing a module's metadata.
  # @api private
  class Metadata < BaseMetadata
    include Puppet::Network::FormatSupport

    def initialize
      super
    end

    def to_json
      data = @data.dup.merge('dependencies' => dependencies)

      contents = data.keys.map do |k|
        value = (JSON.pretty_generate(data[k]) rescue data[k].to_json)
        "#{k.to_json}: #{value}"
      end

      "{\n" + contents.join(",\n").gsub(/^/, '  ') + "\n}\n"
    end

    private

    # Do basic validation on the version parameter.
    def process_version(data)
      validate_version(data['version'])
    end

    # Do basic parsing of the source parameter.  If the source is hosted on
    # GitHub, we can predict sensible defaults for both project_page and
    # issues_url.
    def process_source(data)
      if data['source'] =~ %r[://]
        source_uri = URI.parse(data['source'])
      else
        source_uri = URI.parse("http://#{data['source']}")
      end

      if source_uri.host =~ /^(www\.)?github\.com$/
        source_uri.scheme = 'https'
        source_uri.path.sub!(/\.git$/, '')
        data['project_page'] ||= @data['project_page'] || source_uri.to_s
        data['issues_url'] ||= @data['issues_url'] || source_uri.to_s.sub(/\/*$/, '') + '/issues'
      end

    rescue URI::Error
      return
    end

    # Validates and parses the dependencies.
    def merge_dependencies(data)
      data['dependencies'].each do |dep|
        add_dependency(dep['name'], dep['version_requirement'], dep['repository'])
      end

      # Clear dependencies so @data dependencies are not overwritten
      data.delete 'dependencies'
    end

    # Validates that the version string can be parsed as per SemVer.
    def validate_version(version)
      return if SemVer.valid?(version)

      err = "version string cannot be parsed as a valid Semantic Version"
      raise ArgumentError, "Invalid 'version' field in metadata.json: #{err}"
    end

    # Validates that the version range can be parsed by Semantic.
    def validate_version_range(version_range)
      Semantic::VersionRange.parse(version_range)
    rescue ArgumentError => e
      raise ArgumentError, "Invalid 'version_range' field in metadata.json: #{e}"
    end
  end
end
