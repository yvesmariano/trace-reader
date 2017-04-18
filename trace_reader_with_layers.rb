class CacheMemory
  def initialize(positions, layers=1)
    @lines = []
    @layers = layers
    for i in 0..positions-1
      @lines << []
    end
  end

  # Return true if is a hit and false if is a miss
  def get(position, tag)
    size = @lines[position].size
    if size > 0
      for i in 0..size-1
        if @lines[position][i] == tag
          if i < size-1
            for j in i+1..size-1
              @lines[position][j-1] = @lines[position][j-1]
            end
          end
          @lines[position][size-1] = tag # Last recent used
          return true # Hit
        end
      end
      if size < @layers
        @lines[position] << tag # Last recent used
      else
        for i in 1..size-1
          @lines[position][i-1] = @lines[position][i]
        end
        @lines[position][size-1] = tag # Last recent used
      end
      return false # Miss
    else
      @lines[position] << tag # Last recent used
      return false # Miss
    end
  end
end

def hex2bin(n)
  return n.hex.to_s(2).rjust(n.size*4, '0')
end

acessos, miss, hit, hitrate = 0, 0, 0, 0
puts "Quantas linhas terá a memória cache?"
size = gets.to_i
puts "Quantas colunas (palavras)?"
words = gets.to_i
puts "Quantas camadas?"
layers  = gets.to_i
puts "Qual arquivo de trace deseja ler?"
file = gets.chomp
puts "Lendo #{file} ..."
memory = CacheMemory.new size, layers
bits_size, bits_words = Math.log2(size).to_i, Math.log2(words).to_i

File.open("traces/" + file, "r").each_line do |line|
	if line[0] == '2' then
		line = line[2,8].rjust(8,'0')
		tag = hex2bin(line)[0,32-bits_words]
		index = tag.slice(-bits_size,bits_size).to_i(2)
		if memory.get(index, tag) then
		  hit += 1
		else
		  miss += 1
		end
    acessos += 1
	end
end

hitrate = (hit * 1.0 / acessos)* 100;
puts "Total de acessos: #{acessos}\nHit: #{hit}\nMiss: #{miss}"
puts "Hit rate: %.2f%" % hitrate
