# -------------------------------- *
# Universidade Federal de Goiás    *
# Instituto de Informática         *
# Creation date:   10/08/19        *
# Last updated on: 10/08/19        *
# Author: Marcelo Cardoso Dias     *
# -------------------------------- */

# cafezinho_lexical_analyzer.rb

# -------------------------------------------------- *
# This is a lexical analyzer for Cafezinho language, *
# a programming language invented for a Compilers    *
# study purpose.                                     *
# -------------------------------------------------- */


# REQUIREMENTS ----------------------------------------
require "rly"

# -----------------------------------------------------


class CafezinhoLex < Rly::Lex
	literals '+-*/?!,:;[](){}%=><'

	ignore " \t\n"

	token :COMMENT, /\/\*[^\*]*\*+([^[\/\*]][^\*]*\**)*\//

	token :NUMBER, /\d+/ do |t|
		t.value = t.value.to_i
		t
	end

	token :ID, /[a-zA-Z]+[0-9a-zA-Z]*/
	
	token :RESERVED_WORD, /programa|int|car|intconst|carconst|retorne|leia|escreva|novalinha|se|entao|senao|enquanto|execute/

	on_error do |t|
	    puts "Illegal character: #{t.value}"

	    t.lexer.pos += 1

	    nil
	end
end

str = '2+2/*adsf*/asdf*/'

lex = CafezinhoLex.new(str)

loop do
	t = lex.next

	if t == nil
		break
	end

	puts "#{t} : #{t.type}"
end