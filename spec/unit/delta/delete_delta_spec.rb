require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Lorax::DeleteDelta do
  describe ".new" do
    it "takes one argument" do
      proc { Lorax::DeleteDelta.new(:foo)      }.should_not raise_error(ArgumentError)
      proc { Lorax::DeleteDelta.new(:foo, :bar)}.should     raise_error(ArgumentError)
    end
  end

  describe "#node" do
    it "returns the initalizer argument" do
      Lorax::DeleteDelta.new(:foo).node.should == :foo
    end
  end

  describe "#apply!" do
    context "for an atomic node delta" do
      it "should delete the node" do
        doc1 = xml { root { a1 } }
        doc2 = xml { root }
        node = doc1.at_css("a1")
        delta = Lorax::DeleteDelta.new node

        delta.apply!(doc1)

        doc1.at_css("a1").should be_nil
        node.parent.should == nil
      end
    end

    context "for a subtree delta" do
      it "should delete the subtree" do
        delta, doc1, node = subtree_delta
        delta.apply!(doc1)
        doc1.at_css("a1,b1,b2").should be_nil
        node.parent.should == nil
      end
    end
  end

  def subtree_delta
    doc = xml { root { a1 { b1 ; b2 "hello" } } }
    node = doc.at_css("a1")
    delta = Lorax::DeleteDelta.new node
    [delta, doc, node]
  end

  describe "#descriptor" do
    it "needs a spec"
  end

  describe "#to_s" do
    it "display a patch" do
      delta, _ = subtree_delta
      delta.to_s.should == <<-XML.chomp
--- /root/a1
+++
  <root>
- <a1><b1></b1><b2>hello</b2></a1>
  </root>
XML
    end
  end
end
