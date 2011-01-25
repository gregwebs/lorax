require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Lorax::ModifyDelta do
  describe ".new" do
    it "takes two arguments" do
      proc { Lorax::ModifyDelta.new(:foo)             }.should     raise_error(ArgumentError)
      proc { Lorax::ModifyDelta.new(:foo, :bar)       }.should_not raise_error(ArgumentError)
      proc { Lorax::ModifyDelta.new(:foo, :bar, :quux)}.should     raise_error(ArgumentError)
    end
  end

  describe "#node1" do
    it "returns the first initializer parameter" do
      Lorax::ModifyDelta.new(:foo, :bar).node1.should == :foo
    end
  end

  describe "#node2" do
    it "returns the first initializer parameter" do
      Lorax::ModifyDelta.new(:foo, :bar).node2.should == :bar
    end
  end

  describe "#apply!" do
    context "element node" do
      context "when attributes differ" do
        before do
          doc1 = xml { root { a1(:foo => :bar) } }
          doc2 = xml { root { a1(:bazz => :quux, :once => :twice) } }
          node1 = doc1.at_css("a1")
          node2 = doc2.at_css("a1")
          @doc3 = doc1.dup
          @node3 = @doc3.at_css("a1")
          @delta = Lorax::ModifyDelta.new(node1, node2)
        end

        it "should set the attributes properly" do
          @delta.apply!(@doc3)
          
          @node3["foo"].should be_nil
          @node3["bazz"].should == "quux"
          @node3["once"].should == "twice"
        end

        it 'to_s shows attribute diff' do
          @delta.to_s.should == <<-XML.chomp
--- /root/a1
+++ /root/a1
  <root>
- <a1 foo=\"bar\"></a1>
+ <a1 once=\"twice\" bazz=\"quux\"></a1>
  </root>
XML
        end
      end
    end

    context "text node" do
      before do
        @doc1 = xml { root "hello" }
        @doc2 = xml { root "goodbye" }
        @delta = Lorax::ModifyDelta.new(@doc1.root.children.first, @doc2.root.children.first)
      end

      it "should set the content properly" do
        doc3 = @doc1.dup
        @delta.apply!(doc3)
        doc3.root.content.should == "goodbye"
      end

      it 'to_s shows attribute diff' do
        @delta.to_s.should == <<-XML.chomp
--- /root/text()
+++ /root/text()
  <root>
- hello
+ goodbye
  </root>
XML
      end
    end

    context "when positions differ" do
      it "should move the node" do
        doc1 = xml { root {
            a1 { b1 }
            a2
          } }
        doc2 = xml { root {
            a1
            a2 { b1 }
          } }
        delta = Lorax::ModifyDelta.new(doc1.at_css("b1"), doc2.at_css("b1"))
        doc3 = doc1.dup
        delta.apply!(doc3)
        doc3.at_xpath("/root/a2/b1").should_not be_nil
      end

      it "should move the node to the correct position" do
        delta, doc1, doc2 = modified_tree
        doc3 = doc1.dup
        delta.apply!(doc3)
        doc3.at_xpath("/root/a2/*[2]").name.should == "b2"
      end
    end
  end

  def modified_tree
    doc1 = xml { root {
        a1 { b2 }
        a2 { b1 ; b3 }
      } }
    doc2 = xml { root {
        a1
        a2 { b1 ; b2 ; b3 }
      } }
    delta = Lorax::ModifyDelta.new(doc1.at_css("b2"), doc2.at_css("b2"))
    [delta, doc1, doc2]
  end

  describe "#descriptor" do
    it "needs a spec"
  end

  describe "#to_s" do
    it "display a patch" do
      delta, _ = modified_tree
      delta.to_s.should == <<-XML.chomp
--- /root/a1/b2
+++ /root/a2/b2
  <b1/>
- <b2></b2>
+ <b2></b2>
  <b3/>
XML
    end
  end
end
