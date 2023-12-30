# simple ass statemachine
table = {
  s: %i(t u),
  t: %i(t u),
  u: %i(t u)
}

state = :s
input = "011000101"

puts "-> #{state}"

input.chars.each do |char|
  prev  = state
  i     = char.to_i
  state = table[prev][i]

  puts  "#{prev}(#{i}) -> #{state}"
end
