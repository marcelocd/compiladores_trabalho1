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
	token :comment, /\/\*[^\*]*\*+([^[\*\/]][^\*]*\*+)*\// do end
	
	token :unfinished_comment, /\/\*.*/ do |t|
		if t.type.to_s == 'UNFINISHED_COMMENT'
			puts 'ERRO: COMENTARIO NAO TERMINA'
		end

		nil
	end

	token :intconst, /\d+/ do |t|
		t.value = t.value.to_i
		t
	end

	token :carconst, /[a-zA-Z]/

	token :const_string, /\"[^\"]+\"/

	token :reserved_word, /programa|int|car|intconst|carconst|retorne|leia|escreva|novalinha|se|entao|senao|enquanto|execute|e|ou/

	token :id, /[a-zA-Z]+[0-9a-zA-Z]*/

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
	rule 'DeclFuncVar DeclProg'

	rule 'DeclFuncVar : Tipo id DeclVar ; DeclFuncVar
							| Tipo id [intconst] DeclVar ; DeclFuncVar
							| Tipo id DeclFunc DeclFuncVar
							| '

	rule 'DesclProg : programa Bloco'
	
	rule 'DeclVar : ,id DeclVar
					  | ,id[intconst]DeclVar
					  | '
	
	rule 'DeclFunc : ( ListaParametros )Bloco'
	
	rule 'ListaParametros : 
								 | ListaParametrosCont'

	rule 'ListaParametrosCont : Tipo id
									  | Tipo id[]
									  | Tipo id, ListaParametrosCont
									  | Tipo id[]. ListaParametrosCont'
	
	rule 'Bloco : { ListaDeclVar ListaComando }
					| { ListaDeclVar }'
	
	rule 'ListaDeclVar : 
							 | Tipo id DeclVar ; ListaDeclVar
							 | Tipo id[intconst]DeclVar ; ListaDeclVar'
	
	rule 'Tipo : int
				  | car'
	
	rule 'ListaComando : Comando
							 | Comando ListaComando'

	rule 'Comando : ;
					  | Expr ;
					  | retorne Expr ;
					  | leia LValueExpr :
					  | escreva Expr ;
					  | escreva "cadeiaCaracteres" ;
					  | novalinha ;
					  | se(Expr)entao Comando
					  | se(Expr)entao Comando senao Comando
					  | enquanto(Expr)execute Comando
					  | Bloco'

	rule 'Expr : AssignExpr'

	rule 'AssignExpr : CondExpr
						  | LValueExpr = AssignExpr'

	rule 'CondExpr : OrExpr
						| OrExpr ? Expr : CondExpr'

	rule 'OrExpr : OrExpr ou AndExpr
					 | AndExpr'

	rule 'AndExpr : AndExpr e EqExpr
					  | EqExpr'

	rule 'EqExpr : EqExpr == DesigExpr
					 | EqExpr != DesigExpr
					 | DesigExpr'

	rule 'DesigExpr : DesigExpr < AddExpr
						 | DesigExpr > AddExpr
						 | DesigExpr >= AddExpr
						 | DesigExpr <= AddExpr
						 | AddExpr'

	rule 'AddExpr : AddExpr + MultExpr
					  | AddExpr - MulExpr
					  | MulExpr'

	rule 'MulExpr: MulExpr * UnExpr
					 | MulExpr / UnExpr
					 | MulExpr % UnExpr
					 | UnExpr'

	rule 'UnExpr : - PrimExpr
					 | ! PrimExpr
					 | PrimExpr'

	rule 'LValueExpr : id [Expr]
						  | id'

	rule 'PrimExpr : id (ListExpr)
						| id ()
						| id [Expr]
						| id
						| carconst
						| intconst'

	rule 'ListExpr : AssignExpr
						| ListExpr , AssignExpr'

	# EXAMPLES --------------------------------
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

	# -----------------------------------------
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