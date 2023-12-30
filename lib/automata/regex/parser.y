class Regex::Parser
  options no_result_var
rule
  # https://www.cs.sfu.ca/~cameron/Teaching/384/99-3/regexp-plg.html

  #---+----------------------------------------------------------+
  #   |             ERE Precedence (from high to low)            |
  #---+----------------------------------------------------------+
  # 1 | Collation-related bracket symbols | [==] [::] [..]       |
  # 2 | Escaped characters                | \<special character> |
  # 3 | Bracket expression                | []                   |
  # 4 | Grouping                          | ()                   |
  # 5 | Single-character-ERE duplication  | * + ? {m,n}          |
  # 6 | Concatenation                     |                      |
  # 7 | Anchoring                         | ^ $                  |
  # 8 | Alternation                       | |                    |
  #---+-----------------------------------+----------------------+

  regex
    : union
    | simpleregex

  union
    : regex BAR simpleregex { Union.new(val[0], val[2]) }

  simpleregex
    : concatenation
    | basicregex

  concatenation
    : simpleregex basicregex { Concatenate.new(val[0], val[1]) }

  basicregex
    : star
    | question
    | plus
    | elementaryregex

  star
    : elementaryregex STAR  { Closure.new(val[0]) }

  question
    : elementaryregex QUESTION { Maybe.new(val[0]) }

  plus
    : elementaryregex PLUS { OneOrMore.new(val[0]) }

  elementaryregex
    : group
    | char { Symbol.new(val[0]) }

  group
    : LPAREN regex RPAREN { val[1] }

  char
    : CHAR
end

---- inner
  require "strscan"

  def initialize(str)
    @str = StringScanner.new(str)

    super()
  end

  def parse
    do_parse
  end

  def next_token
    return if @str.eos?

    case
      when char = @str.scan(/[a-z]/i)
        [:CHAR, char]
      when @str.scan(/\(/)
        [:LPAREN, "("]
      when @str.scan(/\)/)
        [:RPAREN, ")"]
      when @str.scan(/\|/)
        [:BAR, "|"]
      when @str.scan(/\*/)
        [:STAR, "*"]
      when @str.scan(/\+/)
        [:PLUS, "+"]
      when @str.scan(/\?/)
        [:QUESTION, "?"]
      else
        raise "scanner error"
    end
  end
