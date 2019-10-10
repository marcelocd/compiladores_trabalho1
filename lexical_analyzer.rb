require "rly"

class CafezinhoLex < Rly::Lex
	literals '+-*/?!,:;[](){}%=><'

	ignore " \t\n"

	token :NUMBER, /\d+/ do |t|
		t.value = t.value.to_i
		t
	end

	token :ID, /[a-zA-Z]+[0-9a-zA-Z]*/
	
	token :RESERVED_WORD, /programa|car|int|retorne|leia|escreva|novalinha|se|entao|senao|enquanto|execute/
end

str = '2+2nesnte
asdf	dei tab'

lex = CafezinhoLex.new(str)

loop do
	t = lex.next

	if t == nil
		break
	end

	puts "#{t} : #{t.type}"
end