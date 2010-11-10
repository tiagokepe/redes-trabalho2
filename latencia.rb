#!/usr/bin/ruby

media = 0
contador = 0
envio = Array.new
recebimento = Array.new
File.readlines(ARGV[0]).each {
	|line| arrline = line.split(' ').collect! {|n| n.to_s } 
	if arrline[0] == "+"
		if envio[arrline[11].to_i].nil?
			envio[arrline[11].to_i] = arrline[1].to_f
		end
	elsif arrline[0] == "r"
		if ( recebimento[arrline[3].to_i] == recebimento[arrline[9].to_i] )
			recebimento[arrline[11].to_i] = arrline[1].to_f
			if  not(  envio[arrline[11].to_i].nil? )
				media= media + ( recebimento[arrline[11].to_i] - envio[arrline[11].to_i] )
				contador+=1
			end
		end
	end
}
media/=contador if contador > 0
puts media 
