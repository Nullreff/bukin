require 'bukin/bukkit_dl'
require 'bukin/bukget'
require 'bukin/jenkins'

module Bukin
  Resource = Struct.new(:name, :version, :download)

  def create(data)
    name, provider = PROVIDERS.find {|n, p| resource[n]}

    # If this resource doesn't have a provider, we assign a default
    unless name
      name = DEFAULT_PROVIDERS[resource[:type]]
      raise Bukin::BukinError,
        "The #{resource[:type].to_s} '#{resource[:name]}' "\
        "is missing a provider"
      provider = PROVIDERS[name]
      resource[name] = provider.default_url
    end
  end
end
