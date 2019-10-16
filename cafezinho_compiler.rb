# -------------------------------- *
# Universidade Federal de Goiás    *
# Instituto de Informática         *
# Creation date:   10/08/19        *
# Last updated on: 13/08/19        *
# Author: Marcelo Cardoso Dias     *
# -------------------------------- */

# cafezinho_compiler.rb

# ------------------------------------------- *
# This is a lexical and syntactic analyzer    *
# implemented in Ruby for Cafezinho language, *
# a programming language invented for a       *
# Compilers study purpose.                    *
# ------------------------------------------- */

# REQUIREMENTS -------------------------------
require "rly"

# --------------------------------------------

# LEXICAL ANALYZER ---------------------------
class CafezinhoLex < Rly::Lex
	reserved_words = {
		'programa' => 'PROGRAMA',
		'retorne' => 'RETORNE',
		'leia' => 'LEIA',
		'escreva' => 'ESCREVA',
		'novalinha' => 'NOVALINHA',
		'se' => 'SE',
		'entao' => 'ENTAO',
		'senao' => 'SENAO',
		'enquanto' => 'ENQUANTO',
		'execute' => 'EXECUTE',
		'e' => 'E',
		'ou' => 'OU',
		'int' => 'INT',
		'car' => 'CAR'
	}

	# IGNORE ----------------------------------
	ignore " \t\n"

	# -----------------------------------------

	# TOKENS ----------------------------------
	token :COMMENT, /\/\*[^\*]*\*+([^[\*\/]][^\*]*\*+)*\// do nil end
	
	token :UNFINISHEDCOMMENT, /\/\*.*/ do  |t|
		puts 'ERRO: COMENTARIO NAO TERMINA'

		t.lexer.pos += 1

		nil
	end

	token :PLUS, /\+/

	token :MINUS, /-/

	token :MULT, /\*/

	token :DIV, /\//

	token :QUESTIONMARK, /\?/

	token :EXCLAMATION, /!/

	token :DOT, /\./

	token :PERCENT, /%/

	token :ATTRIBUTION, /=/

	token :EQUAL, /==/

	token :DIFFERENT, /!=/

	token :GREATER, />/

	token :GEQ, />=/

	token :LESS, /</

	token :LEQ, /<=/

	token :COMMA, /,/

	token :COLON, /:/

	token :SEMICOLON, /;/

	token :LPAREN, /\(/

	token :RPAREN, /\)/

	token :LBRACKET, /\[/

	token :RBRACKET, /\]/

	token :LBRACE, /\{/

	token :RBRACE, /\}/

	token :PROGRAMA, /programa/

	token :RETORNE, /retorne/

	token :LEIA, /leia/

	token :ESCREVA, /escreva/

	token :NOVALINHA, /novalinha/

	token :SE, /se/

	token :ENTAO, /entao/
	
	token :SENAO, /senao/
	
	token :ENQUANTO, /enquanto/
	
	token :EXECUTE, /execute/
	
	token :E, /e/
	
	token :OU, /ou/

	token :INT, /int/

	token :CAR, /car/

	token :ID, /[a-zA-Z]+[0-9a-zA-Z]*/ do |t|
		if reserved_words.has_key?(t.value)
			t.type = reserved_words[t.value]
		end

		t
	end

	token :STRINGCONST, /\"[^\"]*\"/

	token :INTCONST, /\d+/ do |t|
		t.value = t.value.to_i
		t
	end

	token :CARCONST, /[a-zA-Z]/

	#token :EPSILON, //

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
	precedence :left,  'LPAREN', 'RPAREN'
	precedence :left,  'E', 'OU'
	precedence :left,  'GREATER', 'LESS', 'GEQ', 'LEQ', 'EQUAL', 'DIFFERENT'
	precedence :left,  'PLUS', 'MINUS'
	precedence :left,  'MULT', 'DIV'
	precedence :right, 'EXCLAMATION', 'QUESTIONMARK'

	rule 'declfuncvar : declprog'

	rule 'declfuncvar : tipo ID declvar SEMICOLON declfuncvar
							| tipo ID LBRACKET INTCONST RBRACKET declvar SEMICOLON declfuncvar
							| tipo ID declfunc declfuncvar
							| '

	rule 'declprog : PROGRAMA bloco'
	
	rule 'declvar : COMMA ID declvar
					  | COMMA ID LBRACKET INTCONST RBRACKET declvar
					  | '
	
	rule 'declfunc : LPAREN listaparametros RPAREN bloco'
	
	rule 'listaparametros : listaparametroscont 
								 | '

	rule 'listaparametroscont : tipo ID
									  | tipo ID LBRACKET RBRACKET
									  | tipo ID COMMA listaparametroscont
									  | tipo ID LBRACKET RBRACKET DOT listaparametroscont'
	
	rule 'bloco : LBRACE listadeclvar listacomando RBRACE
					| LBRACE listadeclvar RBRACE'
	
	rule 'listadeclvar : tipo ID declvar SEMICOLON listadeclvar
							 | tipo ID LBRACKET INTCONST RBRACKET declvar SEMICOLON listadeclvar
							 | '
	
	rule 'tipo : INT
				  | CAR'
	
	rule 'listacomando : comando
							 | comando listacomando'

	rule 'comando : SEMICOLON
					  | expr SEMICOLON
					  | RETORNE expr SEMICOLON
					  | LEIA lvalueexpr COLON
					  | ESCREVA expr SEMICOLON
					  | ESCREVA STRINGCONST SEMICOLON
					  | NOVALINHA SEMICOLON
					  | SE LPAREN expr RPAREN ENTAO comando
					  | SE LPAREN expr RPAREN ENTAO comando SENAO comando
					  | ENQUANTO LPAREN expr RPAREN EXECUTE comando
					  | bloco'

	rule 'expr : assignexpr'

	rule 'assignexpr : condexpr
						  | lvalueexpr ATTRIBUTION assignexpr'

	rule 'condexpr : orexpr
						| orexpr QUESTIONMARK expr COLON condexpr'

	rule 'orexpr : orexpr OU andexpr
					 | andexpr'

	rule 'andexpr : andexpr E eqexpr
					  | eqexpr'

	rule 'eqexpr : eqexpr EQUAL desigexpr
					 | eqexpr DIFFERENT desigexpr
					 | desigexpr'

	rule 'desigexpr : desigexpr LESS addexpr
						 | desigexpr GREATER addexpr
						 | desigexpr GEQ addexpr
						 | desigexpr LEQ addexpr
						 | addexpr'

	rule 'addexpr : addexpr PLUS multexpr
					  | addexpr MINUS multexpr
					  | multexpr'

	rule 'multexpr : multexpr MULT unexpr
					 	| multexpr DIV unexpr
					 	| multexpr PERCENT unexpr' do |me, me1, op, ue|
		me.value = me1.value.send(op.value, ue.value)
	end

	rule 'multexpr : unexpr' do |me, ue|
		me.value = ue.value
	end

	rule 'unexpr : MINUS primexpr
				 | EXCLAMATION primexpr' do |ue, op, pe|
		ue.value = op.value.send(pe.value)
	end

	rule 'unexpr : primexpr' do |ue, pe|
		ue.value = pe.value
	end

	rule 'lvalueexpr : ID LBRACKET expr RBRACKET' do |lv, id, lb, ex, rb|
		lv.value = id.value.send(lb.value, ex.value, rb.value)
	end

	rule 'lvalueexpr : ID' do |lv, id|
		lv.value = id.value
	end

	rule 'primexpr : ID LPAREN listexpr RPAREN
						| ID LBRACKET expr RBRACKET' do |pe, id, l, x, r|
		pe.value = id.value.send(l.value, x.value, r.value)
	end


	rule 'primexpr : ID LPAREN RPAREN' do |pe, id, l, r|
		pe.value = id.value.send(l.value, r.value)
	end

	rule 'primexpr : ID
						| CARCONST
						| INTCONST' do |pe, r|
		pe.value = r.value
	end

	rule 'listexpr : assignexpr' do |le, ae|
		le.value = ae.value
	end

	rule 'listexpr : listexpr COMMA assignexpr' do |le, le1, co, ae|
		le.value = le1.value.send(co.value, ae.value)
	end
end

# --------------------------------------------

# TESTING ------------------------------------
parser = CafezinhoParse.new(CafezinhoLex.new)

parser.parse('2+2')

=begin
text_file_path = ARGV.first

str = File.read("#{text_file_path}")

str = "asdfadf/*adsfadf***a/"

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