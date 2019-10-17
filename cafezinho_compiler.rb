# -------------------------------- *
# Universidade Federal de Goiás    *
# Instituto de Informática         *
# Creation date:   10/08/19        *
# Last updated on: 16/08/19        *
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
require "rly/helpers"

# --------------------------------------------

# LEXICAL ANALYZER ---------------------------
class CafezinhoLex < Rly::Lex
	current_line = 1

	# IGNORE ----------------------------------
	ignore " \t"

	# -----------------------------------------

	# TOKENS ----------------------------------
	token :LINEBREAK, /\n/ do
		current_line = current_line + 1

		nil
	end

	token :COMMENT, /\/\*[^\*]*\*+([^[\*\/]][^\*]*\*+)*\// do nil end
	
	token :UNFINISHEDCOMMENT, /\/\*.*/ do  |t|
		puts "ERRO: COMENTARIO NAO TERMINA (linha #{current_line})"

		t.lexer.pos += 1

		nil
	end

	token :PLUS, /\+/

	token :MINUS, /-/

	token :MULT, /\*/

	token :DIV, /\//

	token :QUESTIONMARK, /\?/

	token :EXCLAMATION, /!/

	token :PERCENT, /%/

	token :EQUAL, /==/

	token :DIFFERENT, /!=/

	token :ATTRIBUTION, /=/

	token :GEQ, />=/

	token :GREATER, />/

	token :LEQ, /<=/

	token :LESS, /</

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

	token :SENAO, /senao/

	token :SE, /se/

	token :ENTAO, /entao/
	
	token :ENQUANTO, /enquanto/
	
	token :EXECUTE, /execute/
	
	token :E, /e/
	
	token :OU, /ou/

	token :INT, /int/

	token :CAR, /car/

	token :ID, /[a-zA-Z]+[0-9a-zA-Z]*/

	token :STRINGCONST, /\"[^\"]*\"/

	token :INTCONST, /\d+/ do |t|
		t.value = t.value.to_i
		t
	end

	token :CARCONST, /[a-zA-Z]/

	token :EPSILON, //

	# -----------------------------------------

	on_error do |t|
	   puts "ERRO: CARACTER INVALIDO (linha #{current_line}: '#{t.value}')"

	   t.lexer.pos += 1

	   nil
	end
end

# --------------------------------------------

# SYNTACTICAL ANALYZER -----------------------
class CafezinhoParse < Rly::Yacc
	# PRECEDENCE ------------------------------
	precedence :left,  'LPAREN', 'RPAREN'
	#precedence :left,  'LBRACKET', 'RBRACKET'
	#precedence :left,  'LBRACE', 'RBRACE'
	precedence :left,  'E', 'OU'
	precedence :left,  'GREATER', 'LESS', 'GEQ', 'LEQ', 'EQUAL', 'DIFFERENT'
	precedence :left,  'PLUS', 'MINUS'
	precedence :left,  'MULT', 'DIV'
	precedence :right, 'EXCLAMATION', 'QUESTIONMARK'

	# -----------------------------------------

	# RULES -----------------------------------
	rule 'programa : declfuncvar declprog', &collect_to_a

	rule 'declfuncvar : tipo ID declvar SEMICOLON declfuncvar
							| tipo ID LBRACKET INTCONST RBRACKET declvar SEMICOLON declfuncvar
							| tipo ID declfunc declfuncvar
							| ', &collect_to_a

	rule 'declprog : PROGRAMA bloco', &collect_to_a
	
	rule 'declvar : COMMA ID declvar
					  | COMMA ID LBRACKET INTCONST RBRACKET declvar
					  | ', &collect_to_a
	
	rule 'declfunc : LPAREN listaparametros RPAREN bloco', &collect_to_a

	rule 'listaparametros : listaparametroscont
								 | ', &collect_to_a

	rule 'listaparametroscont : tipo ID
									  | tipo ID LBRACKET RBRACKET
									  | tipo ID COMMA listaparametroscont
									  | tipo ID LBRACKET RBRACKET COMMA listaparametroscont', &collect_to_a
	
	rule 'bloco : LBRACE listadeclvar listacomando RBRACE
					| LBRACE listadeclvar RBRACE', &collect_to_a

	rule 'listadeclvar : tipo ID declvar SEMICOLON listadeclvar
					 		 | tipo ID LBRACKET INTCONST RBRACKET declvar SEMICOLON listadeclvar
					 		 | ', &collect_to_a
	
	rule 'tipo : INT
				  | CAR', &collect_to_a

	rule 'listacomando : comando
	                   | comando listacomando', &collect_to_a

	rule 'comando : SEMICOLON
					  | expr SEMICOLON
					  | RETORNE expr SEMICOLON
					  | LEIA lvalueexpr SEMICOLON
					  | ESCREVA expr SEMICOLON
					  | ESCREVA STRINGCONST SEMICOLON
					  | NOVALINHA SEMICOLON
					  | SE LPAREN expr RPAREN ENTAO comando
					  | SE LPAREN expr RPAREN ENTAO comando SENAO comando
					  | ENQUANTO LPAREN expr RPAREN EXECUTE comando
					  | bloco', &collect_to_a
	
	rule 'expr : assignexpr', &collect_to_a

	rule 'assignexpr : condexpr
						  | lvalueexpr ATTRIBUTION assignexpr', &collect_to_a

	rule 'condexpr : orexpr
					   | orexpr QUESTIONMARK expr COLON condexpr', &collect_to_a

	rule 'orexpr : orexpr OU andexpr
					 | andexpr', &collect_to_a

	rule 'andexpr : andexpr E eqexpr
					  | eqexpr', &collect_to_a

	rule 'eqexpr : eqexpr EQUAL desigexpr
					 | eqexpr DIFFERENT desigexpr
					 | desigexpr', &collect_to_a

	rule 'desigexpr : desigexpr LESS addexpr
						 | desigexpr GREATER addexpr
						 | desigexpr GEQ addexpr
						 | desigexpr LEQ addexpr
						 | addexpr', &collect_to_a

	rule 'addexpr : addexpr PLUS mulexpr
					  | addexpr MINUS mulexpr
					  | mulexpr', &collect_to_a

	rule 'mulexpr : mulexpr MULT unexpr
					 	| mulexpr DIV unexpr
					 	| mulexpr PERCENT unexpr
				 	   | unexpr', &collect_to_a

	rule 'unexpr : MINUS primexpr
				 	 | EXCLAMATION primexpr
				 	 | primexpr', &collect_to_a

	rule 'lvalueexpr : ID LBRACKET expr RBRACKET
						  | ID', &collect_to_a

	rule 'primexpr : ID LPAREN listexpr RPAREN
						| ID LPAREN RPAREN
						| ID LBRACKET expr RBRACKET
						| ID
						| CARCONST
						| INTCONST
						| LPAREN expr RPAREN', &collect_to_a

	rule 'listexpr : assignexpr
						| listexpr COMMA assignexpr', &collect_to_a

	# -----------------------------------------

	#store_grammar 'grammar.txt'
end

# --------------------------------------------

# TESTING ------------------------------------
text_file_path = ARGV.first

str = File.read("#{text_file_path}")

lex = CafezinhoLex.new(str)

loop do
	t = lex.next

	if t == nil
		break
	end

	#puts "'#{t}' : #{t.type}"
end

parser = CafezinhoParse.new(lex)

parser.parse(str, true)

# --------------------------------------------