module Diffaroo
  class ModifyDelta < Delta
    attr_accessor :node1, :node2

    def initialize(node1, node2)
      @node1 = node1
      @node2 = node2
    end

    def apply!(doc)
      node = doc.at_xpath(node1.path)
      raise NodeNotFoundError, node1.path unless node

      if node.text? || node.type == Nokogiri::XML::Node::CDATA_SECTION_NODE
        node.content = node2.content
      else
        attributes = attributes_hash(node)
        attributes2 = attributes_hash(node2)
        if attributes != attributes2
          attributes .each { |name, value| node.remove_attribute(name) }
          attributes2.each { |name, value| node[name] = value }
        end
      end

      if node1.path != node2.path
        position = node2.parent.children.index(node2)
        target_parent = doc.at_xpath(node2.parent.path)
        raise NodeNotFoundError, node2.parent.path unless target_parent
        node.unlink
        insert_node(node, target_parent, position)
      end
    end

    private

    def attributes_hash(node)
      # lame.
      node.attributes.inject({}) { |hash, attr| hash[attr.first] = attr.last.value ; hash }
    end
  end
end