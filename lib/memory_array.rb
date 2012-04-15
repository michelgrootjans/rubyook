class MemoryArray
  attr_reader :pointer, :array

  def initialize
    @pointer = 0;
    @array = [0]
    super
  end

  def next
    @pointer += 1
    rebase_array
  end

  def prev
    @pointer -= 1 unless @pointer == 0
  end

  def get
    @array[@pointer]
  end

  def put(value = 0)
    @array[@pointer] = value.to_i
  end

  def increment
    put(get + 1)
  end
  
  def decrement
    put(get - 1)
  end
  
  private
  
  def rebase_array
    if @pointer == @array.length
      @array << 0
    end
  end
end
