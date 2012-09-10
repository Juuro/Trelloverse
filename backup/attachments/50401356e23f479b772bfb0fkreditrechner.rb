credit = ARGV[0].to_f
months = 0
sum = 0

puts credit

while credit > 1000 do
	pay = credit*0.1
	puts ((pay * 10**2).round.to_f / 10**2).to_s+" zahlen"
	credit -= pay
	puts "=>"+((credit * 10**2).round.to_f / 10**2).to_s
	months += 1
	sum += pay
end

puts "Dauer: "+months.to_s
puts "Summe: "+((sum * 10**2).round.to_f / 10**2).to_s