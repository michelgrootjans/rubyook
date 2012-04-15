require_relative 'memory_array'
#!/usr/bin/env ruby
#
# Ook! language interpreter - http://www.dangermouse.net/esoteric/ook.html
#
# Copyright (c) 2010 Alejandro Martinez Ruiz <alex at@ flawedcode dot. org>
# Licensed under 3-clause BSD License (New BSD License).
#
# Ook.run 'Ook. Ook! Ook! Ook? Ook! Ook. Ook! Ook! Ook? Ook!'
#
# As a program: ook file.ook [-v]

class Ook
  VERSION = '0.1.3'

  OokError = Class.new(StandardError)
  UnmatchedStartLoop = Class.new(OokError)
  UnmatchedEndLoop = Class.new(OokError)
  OddNumberOfOoks = Class.new(OokError)
  EndOfInstructions = Class.new(OokError)

  attr_reader :ooks, :mem, :pc, :loops
  attr_writer :verbose
  attr_accessor :ifd, :ofd, :code

  def verbose(msg = nil, print = "puts", &block)
    if(block_given?)
      @efd.print "#{msg}" if @verbose and msg
      yield
      @efd.send(print, " => #{print_memory}") if @verbose and msg
    else
      @efd.send(print, "#{msg}") if @verbose and msg
    end
      
    @verbose
  end

  def initialize(code = '', ifd = STDIN, ofd = STDOUT, efd = STDERR)
    @verbose = false
    @ifd, @ofd, @efd = ifd, ofd, efd
    @code = code
    setup
  end

  def setup
    @pc = 0
    @loops = []
    @mem = MemoryArray.new
    verbose "starting clean memory" do
    end
    parse
  end

  def self.run(code)
    new.run(code)
  end

  def run(code = nil)
    @code = code if code
    setup
    loop { stepi }
  rescue EndOfInstructions
    verbose 'program finished'
  end

  def stepi
    insn = next_insn
    if insn.empty?
      raise UnmatchedStartLoop unless @loops.empty?
      raise EndOfInstructions
    end
    send insn
    @pc += 1
  end

  protected

  def ookd_ookq
    verbose '.? move pointer forward' do
      @mem.next
    end
  end

  def ookq_ookd
    verbose '?. move pointer backward' do
      @mem.prev
    end
  end

  def ookd_ookd
    verbose '.. increment pointer cell' do
      @mem.increment
    end
  end

  def ookx_ookx
    verbose '!! decrement pointer cell' do
      @mem.decrement
    end
  end

  def ookd_ookx
    verbose '.! now reading input'
    @mem.put(@ifd.read(1))
  end

  def ookx_ookd
    verbose "!. now writing =>\t [", "print"
    @ofd.write @mem.get.chr
    verbose " (#{@mem.get})]"
  end

  def ookx_ookq
    verbose '!? evaluating start loop'
    if @mem.get == 0
      verbose "loop skipped: #@pc"
      skip_loop
    else
      verbose "loop entered: #@pc, loops: #{@loops.join ', '}"
      @loops.push @pc
    end
  end

  def ookq_ookx
    verbose '?! evaluating end loop'
    raise UnmatchedEndLoop unless @loops.last
    @mem.get != 0 ? @pc = @loops.last : @loops.pop
  end

  private

  def skip_loop
    nesting = 1
    loop do
      @pc += 1
      insn = next_insn
      raise UnmatchedStartLoop if insn.empty?
      if insn == 'ookq_ookx'
        nesting -= 1
        break if nesting == 0
      elsif insn == 'ookx_ookq'
        nesting += 1
      end
    end
  end

  def parse
    @ooks = @code.scan(/\s*(Ook[!?\.])\s*/).flatten
    raise OddNumberOfOoks unless @ooks.size % 2 == 0
  end

  def next_insn
    @ooks.slice(@pc*2, 2).join('_').downcase.gsub('!', 'x').gsub('?','q').gsub('.','d')
  rescue NoMethodError  # happens when last instruction is an end loop
    ''
  end
  
  def print_memory
    text = []
    @mem.array.each_with_index do |item, index|
      value = ""
      value << "[" if index == @mem.pointer
      value << "#{item}"
      value << "]" if index == @mem.pointer
      text << value
    end
    
    "\t[#{text.join(', ')}]"
    
  end
end

if __FILE__ == $0
  unless ARGV[0].nil?
    ook = Ook.new(File.read ARGV[0])
    ook.verbose = true if ARGV[1]
    ook.run
  else
    STDERR.puts "Unleashed's Ook! interpreter #{Ook::VERSION}\n\nUsage: #{File.basename $0} <file> [-v]"
  end
end

