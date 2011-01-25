module Lorax
  class DeleteDelta < Delta
    attr_accessor :node

    def initialize(node)
      @node = node
    end

    def apply!(document)
      target = document.at_xpath(node.path)
      raise NodeNotFoundError, xpath unless target
      target.unlink
    end

    def descriptor
      [:delete, {:xpath => node.path, :content => node.to_s}]
    end

    def to_s
      super node, nil
    end
  end
end
