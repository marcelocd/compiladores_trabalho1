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
	lineno = 1

	# IGNORE ----------------------------------
	ignore " \t"

	# -----------------------------------------

	# TOKENS ----------------------------------
	token :LINEBREAK, /\n/ do
		lineno = lineno + 1

		nil
	end

	token :COMMENT, /\/\*[^\*]*\*+([^[\*\/]][^\*]*\*+)*\// do nil end
	
	token :UNFINISHEDCOMMENT, /\/\*.*/ do  |t|
		puts "ERRO: COMENTARIO NAO TERMINA (linha #{lineno})"

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
	   puts "ERRO: CARACTER INVALIDO (linha #{lineno}: '#{t.value}')"

	   t.lexer.pos += 1

	   nil
	end
end

# --------------------------------------------

# SYNTACTICAL ANALYZER -----------------------
class CafezinhoParse < Rly::Yacc
	precedence :left,  'LPAREN', 'RPAREN'
	precedence :left,  'LBRACKET', 'RBRACKET'
	precedence :left,  'LBRACE', 'RBRACE'
	precedence :left,  'E', 'OU'
	precedence :left,  'GREATER', 'LESS', 'GEQ', 'LEQ', 'EQUAL', 'DIFFERENT'
	precedence :left,  'PLUS', 'MINUS'
	precedence :left,  'MULT', 'DIV'
	precedence :right, 'EXCLAMATION', 'QUESTIONMARK'

	rule 'programa : declfuncvar declprog'

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
									  | tipo ID LBRACKET RBRACKET COMMA listaparametroscont'
	
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
					  | LEIA lvalueexpr SEMICOLON
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


	rule 'addexpr : addexpr PLUS mulexpr
					  | addexpr MINUS mulexpr
					  | mulexpr'


	rule 'mulexpr : mulexpr MULT unexpr
					 	| mulexpr DIV unexpr
					 	| mulexpr PERCENT unexpr
				 	   | unexpr'


	rule 'unexpr : MINUS primexpr
				 	 | EXCLAMATION primexpr
				 	 | primexpr'

	rule 'lvalueexpr : ID LBRACKET expr RBRACKET
						  | ID'

	rule 'primexpr : ID LPAREN listexpr RPAREN
						| ID LPAREN RPAREN
						| ID LBRACKET expr RBRACKET
						| ID
						| CARCONST
						| INTCONST
						| LPAREN expr RPAREN'

	rule 'listexpr : assignexpr
						| listexpr COMMA assignexpr'

	#store_grammar 'grammar.txt'
end

# --------------------------------------------

# TESTING ------------------------------------
text_file_path = ARGV.first

str = File.read("#{text_file_path}")

#str = 'programa{}'

#=begin
parser = CafezinhoParse.new(CafezinhoLex.new)

parser.parse(str, true)
#=end

=begin
lex = CafezinhoLex.new(str)

loop do
	t = lex.next

	if t == nil
		break
	end

	puts "'#{t}' : #{t.type}"
end
=end

# --------------------------------------------