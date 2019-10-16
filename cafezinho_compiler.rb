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

	token :DOT, /\./

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

	rule 'declfuncvar : declprog'


	rule 'declfuncvar : tipo ID declvar SEMICOLON declfuncvar'

	rule 'declfuncvar : tipo ID LBRACKET INTCONST RBRACKET declvar SEMICOLON declfuncvar'
	rule 'declfuncvar : tipo ID declfunc declfuncvar'

	rule 'declfuncvar : EPSILON'


	rule 'declprog : PROGRAMA bloco'

	
	rule 'declvar : COMMA ID declvar'
	rule 'declvar : COMMA ID LBRACKET INTCONST RBRACKET declvar'
	rule 'declvar : EPSILON'

	
	rule 'declfunc : LPAREN listaparametros RPAREN bloco'

	
	rule 'listaparametros : listaparametroscont 
								 | EPSILON'

	rule 'listaparametroscont : tipo ID'

	rule 'listaparametroscont : tipo ID LBRACKET RBRACKET
									  | tipo ID COMMA listaparametroscont'

	rule 'listaparametroscont : tipo ID LBRACKET RBRACKET DOT listaparametroscont'
	
	rule 'bloco : LBRACE listadeclvar listacomando RBRACE'

	rule 'bloco : LBRACE listadeclvar RBRACE'

	
	rule 'listadeclvar : tipo ID declvar SEMICOLON listadeclvar'

	rule 'listadeclvar : tipo ID LBRACKET INTCONST RBRACKET declvar SEMICOLON listadeclvar'
	rule 'listadeclvar : EPSILON'
	

	rule 'tipo : INT
				  | CAR' do |t, x|
		t.value = x.value
	end

	
	rule 'listacomando : comando
	                   | comando listacomando'


	rule 'comando : SEMICOLON
					  | bloco'

	rule 'comando : expr SEMICOLON
					  | NOVALINHA SEMICOLON'

	rule 'comando : RETORNE expr SEMICOLON
					  | LEIA lvalueexpr COLON
					  | ESCREVA expr SEMICOLON
					  | ESCREVA STRINGCONST SEMICOLON'
	rule 'comando : SE LPAREN expr RPAREN ENTAO comando'
	
	rule 'comando : ENQUANTO LPAREN expr RPAREN EXECUTE comando'

	rule 'comando : SE LPAREN expr RPAREN ENTAO comando SENAO comando'
	

	rule 'expr : assignexpr'


	rule 'assignexpr : condexpr'

	rule 'assignexpr : lvalueexpr ATTRIBUTION assignexpr'

	rule 'condexpr : orexpr'

	rule 'condexpr : orexpr QUESTIONMARK expr COLON condexpr'


	rule 'orexpr : orexpr OU andexpr'

	rule 'orexpr : andexpr'


	rule 'andexpr : andexpr E eqexpr'

	rule 'andexpr : eqexpr'


	rule 'eqexpr : eqexpr EQUAL desigexpr
					 | eqexpr DIFFERENT desigexpr'

	rule 'eqexpr : desigexpr'


	rule 'desigexpr : desigexpr LESS addexpr
						 | desigexpr GREATER addexpr
						 | desigexpr GEQ addexpr
						 | desigexpr LEQ addexpr'

	rule 'desigexpr : addexpr'


	rule 'addexpr : addexpr PLUS multexpr
					  | addexpr MINUS multexpr'

	rule 'addexpr : multexpr'


	rule 'multexpr : multexpr MULT unexpr
					 	| multexpr DIV unexpr
					 	| multexpr PERCENT unexpr'

	rule 'multexpr : unexpr'


	rule 'unexpr : MINUS primexpr
				 | EXCLAMATION primexpr'

	rule 'unexpr : primexpr'


	rule 'lvalueexpr : ID LBRACKET expr RBRACKET'

	rule 'lvalueexpr : ID'


	rule 'primexpr : ID LPAREN listexpr RPAREN
						| ID LBRACKET expr RBRACKET'

	rule 'primexpr : ID LPAREN RPAREN'

	rule 'primexpr : ID
						| CARCONST
						| INTCONST'


	rule 'listexpr : assignexpr'

	rule 'listexpr : listexpr COMMA assignexpr'

	store_grammar 'grammar.txt'
end

# --------------------------------------------

# TESTING ------------------------------------
text_file_path = ARGV.first

str = File.read("#{text_file_path}")

#=begin
parser = CafezinhoParse.new(CafezinhoLex.new)

#parser.parse(str, true)
#=end


#=begin
lex = CafezinhoLex.new(str)

loop do
	t = lex.next

	if t == nil
		break
	end

	#puts "#{t}: #{t.type}"
end
#=end

# --------------------------------------------