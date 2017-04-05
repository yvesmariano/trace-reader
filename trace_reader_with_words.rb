class CacheMemory
  class Item
    attr_accessor :tag, :valid
    def initialize
      @tag = nil
      @valid = false
    end
  end
  def initialize(positions)
    @items = []
    for i in 0..positions-1
      @items << Item.new
    end
  end
  def get(position)
    return @items[position].tag
  end
  def is_valid(position)
    return @items[position].valid
  end
  def put(position, tag)
    @items[position].tag = tag
    @items[position].valid = true
  end
end

def hex2bin(n)
  return n.hex.to_s(2).rjust(n.size*4, '0')
end

require 'json'

acesso, miss, hit, hitrate, history = 0, 0, 0, 0, []
puts "Quantas linhas terá sua memória cache?"
size = gets.to_i
puts "Quantas colunas?"
words = gets.to_i
puts "Qual arquivo de trace deseja ler?"
file = gets.chomp
puts "Lendo #{file}.trace ..."
memory = CacheMemory.new size
bits_size, bits_words = Math.log2(size).to_i, Math.log2(words).to_i

File.open("traces/" + file + ".trace", "r").each_line do |line|
#	if line[0] == 2 then
#		line = line[2,8].rjust(8,'0')
		line = line[4,8]
		tag = hex2bin(line)[0,32-bits_words]
		index = tag.slice(-bits_size,bits_size).to_i(2)
		if(memory.is_valid(index) and memory.get(index) == tag) then
		  hit += 1
		else
		  miss += 1
		  memory.put(index, tag)
		end
		if (acesso % 100 == 0) then
		  hitrate = (hit * 1.0 / (miss + hit))*100;
		  history.push hitrate
		end
		acesso += 1
#	end
end

hitrate = (hit * 1.0 / (miss + hit))*100;
puts "Hit: #{hit}\nMiss: #{miss}"
puts "Hit rate: %.2f%" % hitrate
json = JSON.generate(history)
File.open('data.js', 'w') { |file| file.write("var data = " + json + ";") }
