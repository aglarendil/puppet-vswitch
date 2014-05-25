require "puppet"

module Puppet
  Puppet::Type.newtype(:vs_bridge) do
    @doc = "A Switch - For example 'br-int' in OpenStack"

    ensurable

    newparam(:name) do
      isnamevar
      desc "The bridge to configure"
    end

    newproperty(:external_ids) do
      desc "External IDs for the bridge"
    end

    newproperty(:controller) do
      desc "Controller URL for the bridge"
    end

    newproperty(:datapath_id) do
      desc "Bridge datapath ID"
    end
  end
end
