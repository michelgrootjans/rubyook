class MemoryArray
  attr_reader :pointer, :maxpointer

  def initialize
    @maxpointer = @pointer = 0;
    @array = [0]
    super
  end

  def next
    if @pointer == @maxpointer
      @array << 0
      @maxpointer += 1
    end
    @pointer += 1
  end

  def prev
    @pointer -= 1 unless @pointer == 0
  end

  def get
    @array[@pointer]
  end

  def put(value)
    @array[@pointer] = value
  end

  def +@
    put(get + 1)
  end

  def -@
    put(get - 1)
  end
end
