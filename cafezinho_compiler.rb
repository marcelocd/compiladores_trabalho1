# -------------------------------- *
# Universidade Federal de Goiás    *
# Instituto de Informática         *
# Creation date:   10/08/19        *
# Last updated on: 17/08/19        *
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
#require "byebug"

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

	token :UNFINISHEDCOMMENT, /\/\*.*/ do 
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

	token :STRINGCONST, /\"[^\"]*\"/ do |t|
		if t.value.match(/\n/)
			puts "ERRO: CADEIA DE CARACTERES POSSUI QUEBRA DE LINHA (linha #{current_line})"
		end
	end

	token :INTCONST, /\d+/ do |t|
		t.value = t.value.to_i
		t
	end

	token :CARCONST, /[a-zA-Z]/
	# -----------------------------------------

	on_error do 
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
	precedence :left,  'LBRACKET', 'RBRACKET'
	precedence :left,  'LBRACE', 'RBRACE'
	precedence :left,  'E', 'OU'
	precedence :left,  'GREATER', 'LESS', 'GEQ', 'LEQ', 'EQUAL', 'DIFFERENT'
	precedence :left,  'PLUS', 'MINUS'
	precedence :left,  'MULT', 'DIV'
	precedence :right, 'EXCLAMATION', 'QUESTIONMARK'

	# -----------------------------------------

	# RULES -----------------------------------
	rule 'programa : declfuncvar declprog', &assign_rhs

	rule 'declfuncvar : tipo ID declvar SEMICOLON declfuncvar
							| tipo ID LBRACKET INTCONST RBRACKET declvar SEMICOLON declfuncvar
							| tipo ID declfunc declfuncvar
							| ', &assign_rhs

	rule 'declprog : PROGRAMA bloco', &assign_rhs
	
	rule 'declvar : COMMA ID declvar
					  | COMMA ID LBRACKET INTCONST RBRACKET declvar
					  | ', &assign_rhs
	
	rule 'declfunc : LPAREN listaparametros RPAREN bloco', &assign_rhs

	rule 'listaparametros : listaparametroscont
								 | ', &assign_rhs

	rule 'listaparametroscont : tipo ID
									  | tipo ID LBRACKET RBRACKET
									  | tipo ID COMMA listaparametroscont
									  | tipo ID LBRACKET RBRACKET COMMA listaparametroscont', &assign_rhs
	
	rule 'bloco : LBRACE listadeclvar listacomando RBRACE
					| LBRACE listadeclvar RBRACE', &assign_rhs

	rule 'listadeclvar : tipo ID declvar SEMICOLON listadeclvar
					 		 | tipo ID LBRACKET INTCONST RBRACKET declvar SEMICOLON listadeclvar
					 		 | ', &assign_rhs
	
	rule 'tipo : INT
				  | CAR', &assign_rhs

	rule 'listacomando : comando
	                   | comando listacomando', &assign_rhs

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
					  | bloco', &assign_rhs
	
	rule 'expr : assignexpr', &assign_rhs

	rule 'assignexpr : condexpr
						  | lvalueexpr ATTRIBUTION assignexpr', &assign_rhs

	rule 'condexpr : orexpr
					   | orexpr QUESTIONMARK expr COLON condexpr', &assign_rhs

	rule 'orexpr : orexpr OU andexpr
					 | andexpr', &assign_rhs

	rule 'andexpr : andexpr E eqexpr
					  | eqexpr', &assign_rhs

	rule 'eqexpr : eqexpr EQUAL desigexpr
					 | eqexpr DIFFERENT desigexpr
					 | desigexpr', &assign_rhs

	rule 'desigexpr : desigexpr LESS addexpr
						 | desigexpr GREATER addexpr
						 | desigexpr GEQ addexpr
						 | desigexpr LEQ addexpr
						 | addexpr', &assign_rhs

	rule 'addexpr : addexpr PLUS mulexpr
					  | addexpr MINUS mulexpr
					  | mulexpr', &assign_rhs

	rule 'mulexpr : mulexpr MULT unexpr
					 	| mulexpr DIV unexpr
					 	| mulexpr PERCENT unexpr
				 	   | unexpr', &assign_rhs

	rule 'unexpr : MINUS primexpr
				 	 | EXCLAMATION primexpr
				 	 | primexpr', &assign_rhs

	rule 'lvalueexpr : ID LBRACKET expr RBRACKET
						  | ID', &assign_rhs

	rule 'primexpr : ID LPAREN listexpr RPAREN
						| ID LPAREN RPAREN
						| ID LBRACKET expr RBRACKET
						| ID
						| CARCONST
						| INTCONST
						| LPAREN expr RPAREN', &assign_rhs

	rule 'listexpr : assignexpr
						| listexpr COMMA assignexpr', &assign_rhs

	# -----------------------------------------

	#store_grammar 'grammar.txt'
end

# --------------------------------------------

# TESTING ------------------------------------
text_file_path = ARGV.first

str = File.read("#{text_file_path}")

parser = CafezinhoParse.new(CafezinhoLex.new())

parser.parse(str, true)
# --------------------------------------------