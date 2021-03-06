require "puppet"

Puppet::Type.type(:vs_bridge).provide(:ovs) do
  optional_commands :vsctl => "/usr/bin/ovs-vsctl",
                    :ip    => "/sbin/ip"

  def exists?
    vsctl("br-exists", @resource[:name])
  rescue Puppet::ExecutionFailure
    return false
  end

  def create
    vsctl("add-br", @resource[:name])
    ip("link", "set", @resource[:name], "up")
    external_ids = @resource[:external_ids] if@resource[:external_ids]
    vsctl("set-controller", @resource[:name], @resource[:controller])
    vsctl('set','Bridge',@resource[:name],"other-config:datapath-id=#{@resource[:datapath_id]}")
  end

  def controller
    vsctl("get-controller", @resource[:name])
    rescue Puppet::ExecutionFailure
      return nil
  end

  def controller=(value)
    vsctl("set-controller", @resource[:name], value)
  end

  def datapath_id
    vsctl('get','Bridge',@resource[:name],'datapath_id').gsub('"','')
    rescue Puppet::ExecutionFailure
      return nil
  end

  def datapath_id=(value)
     vsctl('set','Bridge',@resource[:name],"other-config:datapath-id=#{value}")
  end

  def destroy
    vsctl("del-br", @resource[:name])
  end

  def _split(string, splitter=",")
    return Hash[string.split(splitter).map{|i| i.split("=")}]
  end

  def external_ids
    result = vsctl("br-get-external-id", @resource[:name])
    return result.split("\n").join(",")
  end

  def external_ids=(value)
    old_ids = _split(external_ids)
    new_ids = _split(value)

    new_ids.each_pair do |k,v|
      unless old_ids.has_key?(k)
        vsctl("br-set-external-id", @resource[:name], k, v)
      end
    end
  end
end
