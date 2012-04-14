require "memory_array"

describe "a new MemoryArray" do
  let(:array){MemoryArray.new}
  
  it "has 0 at its pointer" do
    array.get.should == 0
  end
  
  it "can set its pointer" do
    array.put(7)
    array.get.should == 7
  end
  
  it "can increment its pointer" do
    array.+@
    array.get.should == 1
  end
  
  it "can decrement its pointer" do
    array.-@
    array.get.should == -1
  end
  
  it "can move to next pointer" do
    array.next
    array.get.should == 0
    array.+@
    array.get.should == 1
    array.prev
    array.get.should == 0
  end
end