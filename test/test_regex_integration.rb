# frozen_string_literal: true

require "test_helper"

class TestRegexIntegration < Minitest::Test
  def test_symbol
    regex = Regex.build("a")

    assert regex.matches?("a")
    refute regex.matches?("b")
    refute regex.matches?("")
  end

  def test_concatenation
    regex = Regex.build("abc")

    assert regex.matches?("abc")
    refute regex.matches?("ab")
    refute regex.matches?("abcd")
  end

  def test_union_star
    regex = Regex.build("(a|b)*")

    assert regex.matches?("")
    assert regex.matches?("abababababbbba")
    assert regex.matches?("aaaaaaabababbbaaabba")
    refute regex.matches?("c")
  end

  def test_union_with_concat
    regex = Regex.build("a(b|c)")

    assert regex.matches?("ab")
    assert regex.matches?("ac")
    refute regex.matches?("a")
    refute regex.matches?("ad")
  end

  def test_closure
    regex = Regex.build("a*")

    assert regex.matches?("")
    assert regex.matches?("a")
    assert regex.matches?("aaaaaaaaaaaaaaa")
    refute regex.matches?("aaaaaaaaaaaaaab")
  end

  def test_one_or_more
    regex = Regex.build("a+")

    refute regex.matches?("")
    assert regex.matches?("a")
    assert regex.matches?("aaaaaaaaaaaaaaa")
    refute regex.matches?("aaaaaaaaaaaaaab")
  end

  def test_maybe
    regex = Regex.build("a?")

    assert regex.matches?("")
    assert regex.matches?("a")
    refute regex.matches?("aa")
    refute regex.matches?("b")
  end

  def test_something_complicated
    regex = Regex.build("(a?(b|c)*ef+)*")

    assert regex.matches?("")
    assert regex.matches?("ef")
    assert regex.matches?("abbbbccccceffff")
    assert regex.matches?("accccefabbbbbefffffeffff")

    refute regex.matches?("ax")
  end
end
