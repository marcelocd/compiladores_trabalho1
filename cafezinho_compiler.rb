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
		'ou' => 'OU'
	}

	# IGNORE ----------------------------------
	ignore " \t\n"

	# -----------------------------------------

	# TOKENS ----------------------------------
	token :COMMENT, /\/\*[^\*]*\*+([^[\*\/]][^\*]*\*+)*\// do nil end
	
	token :UNFINISHEDCOMMENT, /\/\*.*/ do |t|
		if t.type.to_s == 'unfinished_comment'
			puts 'ERRO: COMENTARIO NAO TERMINA'
		end

		nil
	end

	token :PLUS, /\+/

	token :MINUS, /-/

	token :MULT, /\*/

	token :DIV, /\//

	token :QUESTIONMARK, /\?/

	token :EXCLAMATION, /!/

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

	token :INTCONST, /\d+/ do |t|
		t.value = t.value.to_i
		t
	end

	token :STRINGCONST, /\"[^\"]*\"/

	token :ID, /[a-zA-Z]+[0-9a-zA-Z]*/ do |t|
		if reserved_words.has_key?(t.value)
			t.type = reserved_words[t.value]
		end

		t
	end

	token :CARCONST, /[a-zA-Z]/

	# -----------------------------------------

	on_error do |t|
	   puts "ERRO: CARACTER INVALidO"

	   t.lexer.pos += 1

	   nil
	end
end

# --------------------------------------------

# SYNTACTICAL ANALYZER -----------------------
class CafezinhoParse < Rly::Yacc
	rule 'DeclFuncVar : DeclProg'

	rule 'DeclFuncVar : Tipo id DeclVar ";" DeclFuncVar
							| Tipo id "[" intconst "]" DeclVar ";" DeclFuncVar
							| Tipo id DeclFunc DeclFuncVar
							| " "'

	rule 'DesclProg : programa Bloco'
	
	rule 'DeclVar : "," id DeclVar
					  | "," id "[" intconst "]" DeclVar
					  | '
	
	rule 'DeclFunc : "(" ListaParametros ")" Bloco'
	
	rule 'ListaParametros : epsilon
								 | ListaParametrosCont'

	rule 'ListaParametrosCont : Tipo id
									  | Tipo id "[" "]"
									  | Tipo id "," ListaParametrosCont
									  | Tipo id "[" "]" "." ListaParametrosCont'
	
	rule 'Bloco : "{" ListaDeclVar ListaComando "}"
					| "{" ListaDeclVar "}"'
	
	rule 'ListaDeclVar : " "
							 | Tipo id DeclVar ";" ListaDeclVar
							 | Tipo id "[" intconst "]" DeclVar ";" ListaDeclVar'
	
	rule 'Tipo : int
				  | car'
	
	rule 'ListaComando : Comando
							 | Comando ListaComando'

	rule 'Comando : ";"
					  | Expr ";"
					  | retorne Expr ";"
					  | leia LValueExpr ":"
					  | escreva Expr ";"
					  | escreva const_string ";"
					  | novalinha ";"
					  | se "(" Expr ")" entao Comando
					  | se "(" Expr ")" entao Comando senao Comando
					  | enquanto "(" Expr ")" execute Comando
					  | Bloco'

	rule 'Expr : AssignExpr'

	rule 'AssignExpr : CondExpr
						  | LValueExpr "=" AssignExpr'

	rule 'CondExpr : OrExpr
						| OrExpr "?" Expr ":" CondExpr'

	rule 'OrExpr : OrExpr ou AndExpr
					 | AndExpr'

	rule 'AndExpr : AndExpr e EqExpr
					  | EqExpr'

	rule 'EqExpr : EqExpr "=" "=" DesigExpr
					 | EqExpr "!" "=" DesigExpr
					 | DesigExpr'

	rule 'DesigExpr : DesigExpr "<" AddExpr
						 | DesigExpr ">" AddExpr
						 | DesigExpr ">" "=" AddExpr
						 | DesigExpr "<" "=" AddExpr
						 | AddExpr'

	rule 'AddExpr : AddExpr "+" MultExpr
					  | AddExpr "-" MulExpr
					  | MulExpr'

	rule 'MulExpr: MulExpr "*" UnExpr
					 | MulExpr "/" UnExpr
					 | MulExpr "%" UnExpr
					 | UnExpr'

	rule 'UnExpr : "-" PrimExpr
					 | "!" PrimExpr
					 | PrimExpr'

	rule 'LValueExpr : id "[" Expr "]"
						  | id'

	rule 'PrimExpr : id "(" ListExpr ")"
						| id "(" ")"
						| id "[" Expr "]"
						| id
						| carconst
						| intconst'

	rule 'ListExpr : AssignExpr
						| ListExpr "," AssignExpr'
end

# --------------------------------------------

str = 'enquanto'

lex = CafezinhoLex.new(str)

loop do
	t = lex.next

	if t == nil
		break
	end

	puts "#{t} : #{t.type}"
end


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