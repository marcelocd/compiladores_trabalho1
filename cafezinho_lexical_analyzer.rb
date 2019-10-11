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
   # LITERALS -----------------------------------------
	literals '+-*/?!,:;[](){}%=><'

	# --------------------------------------------------

	# IGNORE -------------------------------------------
	ignore " \t\n"

	# --------------------------------------------------

	# TOKENS -------------------------------------------
	token :COMMENT, /\/\*[^\*]*\*+([^[\*\/]][^\*]*\*+)*\// do end
	
	token :UNFINISHED_COMMENT, /\/\*.*/ do |t|
		if t.type.to_s == 'UNFINISHED_COMMENT'
			puts 'ERRO: COMENTARIO NAO TERMINA'
		end

		nil
	end

	token :NUMBER, /\d+/ do |t|
		t.value = t.value.to_i
		t
	end

	token :CONST_STRING, /\"[^\"]+\"/

	token :RESERVED_WORD, /programa|int|car|intconst|carconst|retorne|leia|escreva|novalinha|se|entao|senao|enquanto|execute|e|ou/

	token :ID, /[a-zA-Z]+[0-9a-zA-Z]*/

	# --------------------------------------------------

	on_error do |t|
	   puts "ERRO: CARACTER INVALIDO"

	   t.lexer.pos += 1

	   nil
	end
end

=begin
text_file_path = ARGV.first

str = File.read("#{text_file_path}")

lex = CafezinhoLex.new(str)

loop do
	t = lex.next

	if t == nil
		break
	end

	puts "#{t} : #{t.type}"
end
=end