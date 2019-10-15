require "rly.rb"

class CalcLex < Rly::Lex
  literals '+-*/'
  ignore " \t\n"
  token :NUMBER, /\d+/ do |t|
    t.value = t.value.to_i
    t
  end

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end

class CalcParse < Rly::Yacc
	precedence :left,  '+', '-'
	precedence :left,  '*', '/'
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

str = "2*2+2"

parser = CalcParse.new(CalcLex.new())

puts parser.parse(str)

lex = CalcLex.new(str)

loop do
	t = lex.next

	if t == nil
		break
	end

	puts "#{t} : #{t.type}"
end