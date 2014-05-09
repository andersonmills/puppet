module Puppet::ModuleTool::Requirements

  REQUIREMENT_NAMES = {
    'PUPPET' => Puppet.version,
    'FACTER' => 0,
    'HIERA'  => 0,
  }

  # get list working NOW


  # suggestions from pieter
#  def add_requirements_constraints_to_graph(graph)
#    graph.add_graph_constraint('Puppet Version') do |nodes|
#      Puppet::ModuleTool::Requirements.process_requirements_for('puppet', nodes)
#    end
#
#    graph.add_graph_constraint('Facter Version') do |nodes|
#      Puppet::ModuleTool::Requirements.process_requirements_for('facter', nodes)
#    end
#
#    graph.add_graph_constraint('Hiera Version') do |nodes|
#      Puppet::ModuleTool::Requirements.process_requirements_for('hiera', nodes)
#    end
#  end
#
#  def Puppet::ModuleTool::Requirements.process_requirements_for(name, nodes)
#    nodes = nodes.reject { |x| x.is_a? InstalledModules::ModuleRelease }
#    version = REQUIREMENTS[name]
#
#    nodes.all? do |node|
#      requirements_list = get_requirements_for(name, node.metadata)
#      requirements_list.all? { |range| range === version }
#    end
#  end
#
#  def self.add_requirements_constraints_to_graph(graph)
#    add_requirements_constraints_to_graph(graph)
#  end
#
#  def self.has_pe_requirement?(metadata)
#    requirements = metadata['requirements'] || []
#    requirements.any? { |req| req['name'].upcase == 'PE' }
#  end
#
#  def self.meets_all_requirements(metadata)
#    # return true unless Puppet.enterprise?
#
#    requirements = metadata['requirements'] || []
#
#    requirements_fulfilled = {}
#
#    REQUIREMENT_NAMES.each do |req_name|
#      a_requirements = requirements.select { |req| req['name'].upcase == req_name }
#      a_versions = a_requirements.map { |req| req['version_requirement'] }
#      unless a_versions.empty? 
#        requirements_fulfilled[req_name] = a_versions.all? { |range| match_range(range) }
#      end
#    end
#
#    # puppet_requirements = requirements.select { |req| req['name'].upcase == 'PUPPET' }
#    # puppet_versions = puppet_requirements.map { |req| req['version_requirement'] }
#    # puppet_requirements = requirements.select { |req| req['name'].upcase == 'PUPPET' }
#    # puppet_versions = puppet_requirements.map { |req| req['version_requirement'] }
#    # puppet_requirements = requirements.select { |req| req['name'].upcase == 'PUPPET' }
#    # puppet_versions = puppet_requirements.map { |req| req['version_requirement'] }
#    # puppet_requirements = requirements.select { |req| req['name'].upcase == 'PUPPET' }
#    # puppet_versions = puppet_requirements.map { |req| req['version_requirement'] }
#    #
#    # pe_versions.all? { |range| match_pe_range(range) }
#  end
#
#  def self.match_pe_range(range)
#    return false unless Puppet.enterprise?
#
#    version = Semantic::Version.parse(Puppet.pe_version)
#    range   = Semantic::VersionRange.parse(range)
#    range.include?(version)
#  end
#
#  def self.match_pe_range(range)
#    return false unless Puppet.enterprise?
#
#    version = Semantic::Version.parse(Puppet.pe_version)
#    range   = Semantic::VersionRange.parse(range)
#    range.include?(version)
#  end
#
#
#  def self.add_pe_requirements_constraints_to_graph(graph)
#    graph.add_graph_constraint('PE Version') do |nodes|
#      nodes.all? do |node|
#        node.is_a?(Puppet::ModuleTool::InstalledModules::ModuleRelease) ||
#          Puppet::ModuleTool.meets_all_pe_requirements(node.metadata)
#      end
#    end
#  end
#
#
#
#  def self.meets_all_pe_requirements(metadata)
#    return true unless Puppet.enterprise?
#
#    requirements = metadata['requirements'] || []
#    pe_requirements = requirements.select { |req| req['name'].upcase == 'PE' }
#    pe_versions = pe_requirements.map { |req| req['version_requirement'] }
#
#    pe_versions.all? { |range| match_pe_range(range) }
#  end
#
#  def self.match_pe_range(range)
#    return false unless Puppet.enterprise?
#
#    version = Semantic::Version.parse(Puppet.pe_version)
#    range   = Semantic::VersionRange.parse(range)
#    range.include?(version)
#  end
#
#  def self.has_pe_requirement?(metadata)
#    requirements = metadata['requirements'] || []
#    requirements.any? { |req| req['name'].upcase == 'PE' }
#  end
#
#  def self.meets_all_requirements(metadata)
#    # return true unless Puppet.enterprise?
#
#    requirements = metadata['requirements'] || []
#
#    requirements_fulfilled = {}
#
#    REQUIREMENT_NAMES.each do |req_name|
#      a_requirements = requirements.select { |req| req['name'].upcase == req_name }
#      a_versions = a_requirements.map { |req| req['version_requirement'] }
#      unless a_versions.empty? 
#        requirements_fulfilled[req_name] = a_versions.all? { |range| match_range(range) }
#      end
#    end
#
#    # puppet_requirements = requirements.select { |req| req['name'].upcase == 'PUPPET' }
#    # puppet_versions = puppet_requirements.map { |req| req['version_requirement'] }
#    # puppet_requirements = requirements.select { |req| req['name'].upcase == 'PUPPET' }
#    # puppet_versions = puppet_requirements.map { |req| req['version_requirement'] }
#    # puppet_requirements = requirements.select { |req| req['name'].upcase == 'PUPPET' }
#    # puppet_versions = puppet_requirements.map { |req| req['version_requirement'] }
#    # puppet_requirements = requirements.select { |req| req['name'].upcase == 'PUPPET' }
#    # puppet_versions = puppet_requirements.map { |req| req['version_requirement'] }
#    #
#    # pe_versions.all? { |range| match_pe_range(range) }
#  end
#
#  def self.match_pe_range(range)
#    return false unless Puppet.enterprise?
#
#    version = Semantic::Version.parse(Puppet.pe_version)
#    range   = Semantic::VersionRange.parse(range)
#    range.include?(version)
#  end
#
#  def self.match_pe_range(range)
#    return false unless Puppet.enterprise?
#
#    version = Semantic::Version.parse(Puppet.pe_version)
#    range   = Semantic::VersionRange.parse(range)
#    range.include?(version)
#  end
#
  
end

