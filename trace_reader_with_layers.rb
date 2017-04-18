class CacheMemory
  class Layer
    attr_accessor :tag, :valid
    def initialize()
      @tag = nil
      @valid = false
    end
  end
  class Line
    attr_accessor :layers
    def initialize(layers=1)
      @layers = []
    end
  end

  def initialize(positions, layers=1)
    @lines = []
    for i in 0..positions-1
      @lines << Line.new(layers)
    end
  end

  # Return true if is a hit and false if is a miss
  def get(i, tag)
    @lines[i].tag = tag
    @lines[i].valid = true
  end
end

def hex2bin(n)
  return n.hex.to_s(2).rjust(n.size*4, '0')
end

require 'json'

acesso, miss, hit, hitrate, history = 0, 0, 0, 0, []
puts "Quantas linhas terá a memória cache?"
size = gets.to_i
puts "Quantas colunas (palavras)?"
words = gets.to_i
puts "Quantas camadas?"
layers  = gets.to_i
puts "Qual arquivo de trace deseja ler?"
file = gets.chomp
puts "Lendo #{file}.trace ..."
memory = CacheMemory.new size, layers
bits_size, bits_words = Math.log2(size).to_i, Math.log2(words).to_i

File.open("traces/" + file, "r").each_line do |line|
	if line[0] == 2 then
		line = line[2,8].rjust(8,'0')
		tag = hex2bin(line)[0,32-bits_words]
		index = tag.slice(-bits_size,bits_size).to_i(2)
		if memory.get(index, tag) then
		  hit += 1
		else
		  miss += 1
		end
#	end
end

hitrate = (hit * 1.0 / (miss + hit))*100;
puts "Hit: #{hit}\nMiss: #{miss}"
puts "Hit rate: %.2f%" % hitrate
json = JSON.generate(history)
File.open('data.js', 'w') { |file| file.write("var data = " + json + ";") }
