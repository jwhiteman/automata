# frozen_string_literal: true

require "test_helper"

class TestNFA < Minitest::Test

  def test_nondeterminism
    rules = {
      "1" => { "a" => Set["1"], "b" => Set["1", "2"] },
      "2" => { "a" => Set["3"], "b" => Set["3"]      },
      "3" => { "a" => Set["4"], "b" => Set["4"]      }
    }
    nfa = NFA.new(Set["1"], Set["4"], rules)

    assert nfa.accepts?("bab")
    refute nfa.accepts?("abb")
    assert nfa.accepts?("bbbbb")
    refute nfa.accepts?("bbabb")
    assert nfa.accepts?("aaaaaaaaaabaa")
    refute nfa.accepts?("bbbbbbbbbbabb")
  end

  def test_free_moves
    rules = {
      "1" => { "ε" => Set["2", "4"] },
      "2" => { "a" => Set["3"] },
      "3" => { "a" => Set["2"] },
      "4" => { "a" => Set["5"] },
      "5" => { "a" => Set["6"] },
      "6" => { "a" => Set["4"] },
    }

    nfa = NFA.new(Set["1"], Set["2", "4"], rules)

    assert nfa.accepts?("aa")
    assert nfa.accepts?("aaa")
    refute nfa.accepts?("aaaaa")
    assert nfa.accepts?("aaaaaa")
  end

  # example: /(1|0)*1/
  def test_star_regex
    rules = {
      "a" => { "ε" => Set["b", "h"] },
      "b" => { "ε" => Set["c", "d"] },
      "c" => { "0" => Set[],    "1" => Set["e"] },
      "d" => { "0" => Set["f"], "1" => Set[] },
      "e" => { "ε" => Set["g"] },
      "f" => { "ε" => Set["g"] },
      "g" => { "ε" => Set["a", "h"] },
      "h" => { "ε" => Set["i"] },
      "i" => { "0" => Set[],    "1" => Set["j"] }
    }

    nfa = NFA.new(Set["a"], Set["j"], rules)

    assert nfa.accepts?("1")
    refute nfa.accepts?("0")
    assert nfa.accepts?("11")
    assert nfa.accepts?("01")
    assert nfa.accepts?("000000000000000000001")
    refute nfa.accepts?("111111111111111111110")
  end

  def test_nfa_rules_to_graphviz
    rules = {
      "a" => { "ε" => Set["b", "h"] },
      "b" => { "ε" => Set["c", "d"] },
      "c" => { "0" => Set[],    "1" => Set["e"] },
      "d" => { "0" => Set["f"], "1" => Set[] },
      "e" => { "ε" => Set["g"] },
      "f" => { "ε" => Set["g"] },
      "g" => { "ε" => Set["a", "h"] },
      "h" => { "ε" => Set["i"] },
      "i" => { "0" => Set[],    "1" => Set["j"] },
      "j" => { "0" => Set[],    "1" => Set[] }
    }

    graphviz = NFA.nfa_rules_to_graphviz(rules)
    assert_equal <<~S.chomp, graphviz
digraph finite_state_machine {
  fontname="Helvetica,Arial,sans-serif"
  node [fontname="Helvetica,Arial,sans-serif"]
  edge [fontname="Helvetica,Arial,sans-serif"]
  rankdir=LR;
  node [shape = circle];
  a -> b [label = "ε"];
  a -> h [label = "ε"];
  b -> c [label = "ε"];
  b -> d [label = "ε"];
  c -> e [label = "1"];
  d -> f [label = "0"];
  e -> g [label = "ε"];
  f -> g [label = "ε"];
  g -> a [label = "ε"];
  g -> h [label = "ε"];
  h -> i [label = "ε"];
  i -> j [label = "1"];
}
S
  end

  def test_graphviz_to_nfa_rules
    graphviz = <<-S.chomp
digraph finite_state_machine {
  fontname="Helvetica,Arial,sans-serif"
  node [fontname="Helvetica,Arial,sans-serif"]
  edge [fontname="Helvetica,Arial,sans-serif"]
  rankdir=LR;
  node [shape = circle];
  a -> b [label = "ε"];
  a -> h [label = "ε"];
  b -> c [label = "ε"];
  b -> d [label = "ε"];
  c -> e [label = "1"];
  d -> f [label = "0"];
  e -> g [label = "ε"];
  f -> g [label = "ε"];
  g -> a [label = "ε"];
  g -> h [label = "ε"];
  h -> i [label = "ε"];
  i -> j [label = "1"];
}
S
    assert_equal({
      "a" => { "ε" => Set["b", "h"] },
      "b" => { "ε" => Set["c", "d"] },
      "c" => { "0" => Set[],    "1" => Set["e"] },
      "d" => { "0" => Set["f"], "1" => Set[] },
      "e" => { "ε" => Set["g"] },
      "f" => { "ε" => Set["g"] },
      "g" => { "ε" => Set["a", "h"] },
      "h" => { "ε" => Set["i"] },
      "i" => { "0" => Set[],    "1" => Set["j"] },
      "j" => { "0" => Set[],    "1" => Set[] }
    }, NFA.graphviz_to_nfa_rules(graphviz))
  end
end
