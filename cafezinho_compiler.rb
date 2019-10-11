# -------------------------------- *
# Universidade Federal de Goiás    *
# Instituto de Informática         *
# Creation date:   10/08/19        *
# Last updated on: 11/08/19        *
# Author: Marcelo Cardoso Dias     *
# -------------------------------- */

# cafezinho_compiler.rb

# -------------------------------------------- *
# This is a lexical and syntactic analyzer for *
# Cafezinho language, a programming language   *
# invented for a Compilers study purpose.      *
# -------------------------------------------- */

# REQUIREMENTS -------------------------------
require "rly"

# --------------------------------------------

# LEXICAL ANALYZER ---------------------------
class CafezinhoLex < Rly::Lex
   # LITERALS --------------------------------
	literals '+-*/?!,:;[](){}%=><'

	# -----------------------------------------

	# IGNORE ----------------------------------
	ignore " \t\n"

	# -----------------------------------------

	# TOKENS ----------------------------------
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

	# -----------------------------------------

	on_error do |t|
	   puts "ERRO: CARACTER INVALIDO"

	   t.lexer.pos += 1

	   nil
	end
end

# --------------------------------------------

# SYNTACTICAL ANALYZER -----------------------
class CafezinhoParse < Rly::Yacc
	rule 'statement : expression' do |st, e|
		st.value = e.value
	end

	rule 'expression : expression "+" expression
	                 | expression "-" expression
	                 | expression "*" expression
	                 | expression "/" expression' do |ex, e1, op, e2|
		ex.value = e1.value.send(op.value, e2.value)
	end

	rule 'expression : NUMBER' do |ex, n|
		ex.value = n.value
	end
end

# --------------------------------------------

# TESTING ------------------------------------
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

# --------------------------------------------