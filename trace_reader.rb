class CacheMemory
  class CacheMemoryItem
    attr_accessor :address, :content, :valid
    def initialize
      @address = "0"*8
      @content = "0"*8
      @valid = false
    end
  end
  def initialize(positions)
    @items = []
    for i in 0..positions-1
      @items.push CacheMemoryItem.new
    end
  end
  def get(position)
    return @items[position].address
  end
  def is_valid(position)
    return @items[position].valid
  end
  def put(position, address)
    @items[position].address = address
    @items[position].valid = true
  end
end

def hex2bin(n)
  return n.hex.to_s(2).rjust(n.size*4, '0')
end

require 'json'

acesso, miss, hit, hitrate, history = 0, 0, 0, 0, []
puts "Qual será o tamanho da memória cache?"
size = gets.to_i
memory = CacheMemory.new size
bits = Math.log2(size).to_i
File.open("traces/swim.trace", "r").each_line do |line|
  line = line[4,8]
  index = hex2bin(line).slice(-bits,bits).to_i(2)
  if(memory.is_valid(index) and memory.get(index) == line)
    hit += 1
  else
    miss += 1
    memory.put(index, line)
  end
  if (acesso % 100 == 0) then
    hitrate = (hit * 1.0 / (miss + hit))*100;
    history.push hitrate
  end
  acesso += 1
end
hitrate = (hit * 1.0 / (miss + hit))*100;
puts "Hit: #{hit}\nMiss: #{miss}\nHit rate: #{hitrate}%"
json = JSON.generate(history)
File.open('data.js', 'w') { |file| file.write("var data = " + json + ";") }
