# frozen_string_literal: true

require "test_helper"

module Regex
  class TestParser < Minitest::Test
    def test_symbol
      ast = Parser.new("a").parse

      assert_equal Symbol.new("a"), ast
    end

    def test_concat_symbol_pair
      ast = Parser.new("ab").parse

      assert_equal Concatenate.new(
                     Symbol.new("a"),
                     Symbol.new("b")
                  ), ast
    end

    def test_concat_symbol_triple
      ast = Parser.new("abc").parse

      assert_equal Concatenate.new(
                     Concatenate.new(
                       Symbol.new("a"),
                       Symbol.new("b")
                    ),
                    Symbol.new("c")
                  ), ast
    end

    def test_simple_union
      ast = Parser.new("(a|b)").parse

      assert_equal Union.new(
                     Symbol.new("a"),
                     Symbol.new("b")
                   ), ast
    end

    def test_nested_union
      ast = Parser.new("(a|(b|c))").parse

      assert_equal Union.new(
                     Symbol.new("a"),
                     Union.new(
                       Symbol.new("b"),
                       Symbol.new("c")
                     )
                   ), ast
    end

    def test_concatenated_union
      ast = Parser.new("(a|b)(c|d)").parse

      assert_equal Concatenate.new(
                     Union.new(
                       Symbol.new("a"),
                       Symbol.new("b")
                     ),
                     Union.new(
                       Symbol.new("c"),
                       Symbol.new("d")
                     ),
                   ), ast
    end

    def test_closure
      ast = Parser.new("a*").parse

      assert_equal Closure.new(Symbol.new("a")), ast
    end

    def test_closure_concatenated_group
      ast = Parser.new("a(bc)*").parse

      assert_equal Concatenate.new(
                     Symbol.new("a"),
                     Closure.new(
                       Concatenate.new(
                         Symbol.new("b"),
                         Symbol.new("c")
                       )
                     )
                   ), ast
    end

    def test_closure_alternation
      ast = Parser.new("a(b|c)*").parse

      assert_equal Concatenate.new(
                     Symbol.new("a"),
                     Closure.new(
                       Union.new(
                         Symbol.new("b"),
                         Symbol.new("c")
                       )
                     )
                   ), ast
    end

    def test_maybe_symbol
      ast = Parser.new("a?").parse

      assert_equal Maybe.new(Symbol.new("a")), ast
    end

    def test_maybe_string
      ast = Parser.new("ab?").parse

      assert_equal Concatenate.new(
                     Symbol.new("a"),
                     Maybe.new(Symbol.new("b"))
                   ), ast
    end

    def test_maybe_union
      ast = Parser.new("(a|b)?").parse

      assert_equal Maybe.new(
                     Union.new(
                       Symbol.new("a"),
                       Symbol.new("b")
                     )
                   ), ast
    end

    def test_one_or_more_symbol
      ast = Parser.new("a+").parse

      assert_equal OneOrMore.new(Symbol.new("a")), ast
    end

    def test_one_or_more_double
      ast = Parser.new("ab+").parse

      assert_equal Concatenate.new(
                     Symbol.new("a"),
                     OneOrMore.new(Symbol.new("b"))
                   ), ast
    end

    def test_one_or_more_alternation
      ast = Parser.new("(a|b)+").parse

      assert_equal OneOrMore.new(
                     Union.new(
                       Symbol.new("a"),
                       Symbol.new("b"),
                     )
                   ), ast
    end
  end
end
