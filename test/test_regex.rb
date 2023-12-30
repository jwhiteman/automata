# frozen_string_literal: true

require "test_helper"

module Regex
  class TestRegex < Minitest::Test
    def test_epsilon
      nfa = Regex::Epsilon.new.to_nfa

      assert nfa.accepts?("")
      refute nfa.accepts?("a")
    end

    def test_symbol
      nfa = Regex::Symbol.new("a").to_nfa

      refute nfa.accepts?("")
      refute nfa.accepts?("b")
      assert nfa.accepts?("a")
    end

    def test_union
      pattern = Union.new(Symbol.new("a"), Symbol.new("b"))

      # assert_equal "/a|b/", pattern.inspect

      nfa = pattern.to_nfa
      assert nfa.accepts?("a")
      assert nfa.accepts?("b")
      refute nfa.accepts?("c")
      refute nfa.accepts?("ab")
    end

    def test_concatenate
      pattern = Concatenate.new(
                  Symbol.new("a"),
                  Symbol.new("b")
                )

      # assert_equal "/ab/", pattern.inspect

      nfa = pattern.to_nfa

      refute nfa.accepts?("a")
      assert nfa.accepts?("ab")
      refute nfa.accepts?("abc")
      refute nfa.accepts?("abb")
    end

    def test_union_of_concatenations
      pattern = Union.new(
                  Concatenate.new(Concatenate.new(Symbol.new("a"), Symbol.new("b")), Symbol.new("c")),
                  Concatenate.new(Concatenate.new(Symbol.new("a"), Symbol.new("b")), Symbol.new("x"))
                )

      # assert_equal "/abc|abx/", pattern.inspect

      nfa = pattern.to_nfa
      assert nfa.accepts?("abc")
      assert nfa.accepts?("abx")
      refute nfa.accepts?("aby")
    end

    def test_concatenation_of_unions
      pattern = Concatenate.new(
                  Union.new(Symbol.new("a"), Symbol.new("b")),
                  Union.new(Symbol.new("x"), Symbol.new("y")),
                )

      # assert_equal "/(a|b)(x|y)/", pattern.inspect

      nfa = pattern.to_nfa
      assert nfa.accepts?("ax")
      assert nfa.accepts?("ay")
      assert nfa.accepts?("bx")
      assert nfa.accepts?("by")

      refute nfa.accepts?("ac")
      refute nfa.accepts?("bc")
    end

    # /a*/
    def test_closure_simple
      pattern = Closure.new(Symbol.new("a"))

      nfa = pattern.to_nfa

      assert nfa.accepts?("")
      assert nfa.accepts?("a")
      assert nfa.accepts?("aaaaaaaaaaaaaa")
      refute nfa.accepts?("b")
    end

    # figure 3.43, page 162: /(a|b)*abb/
    def test_figure_3_43_dragon_book
      pattern =  Concatenate.new(
                   Closure.new(
                     Union.new(
                       Symbol.new("a"),
                       Symbol.new("b"),
                     )
                   ),
                   Concatenate.new(
                     Concatenate.new(
                       Symbol.new("a"),
                       Symbol.new("b")
                     ),
                     Symbol.new("b")
                   )
                 )

      nfa = pattern.to_nfa

      assert nfa.accepts?("abb")
      refute nfa.accepts?("ab")

      assert nfa.accepts?("aaaabbbababaaaaaabbbbbabb")
      refute nfa.accepts?("aaaabbbababaaaaaabbbbbab")
      refute nfa.accepts?("aaaabbbababaaaaaabbbbbaba")

      assert nfa.accepts?("abbabb")
      refute nfa.accepts?("abbab")
      refute nfa.accepts?("abbaba")
    end

    # /(a(|b))*/  => /(ab?)*/
    def test_closure_2
      pattern = Closure.new(
                  Concatenate.new(
                    Symbol.new("a"),
                    Union.new(Epsilon.new, Symbol.new("b"))
                  )
                )

      # assert_equal "/(a(|b))*/", pattern.inspect
      nfa = pattern.to_nfa

      assert nfa.accepts?("")

      refute nfa.accepts?("b")
      assert nfa.accepts?("a")
      assert nfa.accepts?("ab")
      assert nfa.accepts?("abab")
      assert nfa.accepts?("abaab")
      refute nfa.accepts?("abba")
      assert nfa.accepts?("aba")
    end
  end
end
