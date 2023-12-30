# frozen_string_literal: true

require "test_helper"

class DFA
  class TestDFA < Minitest::Test
    def test_dfa
      rules = {
        1 => { "a" => 2, "b" => 1 },
        2 => { "a" => 2, "b" => 3 }
      }

      dfa = DFA.new(start_state: 1, accept_states: [3], rules: rules)

      assert dfa.accepting?("baaab")
      refute dfa.accepting?("a")
      refute dfa.accepting?("baa")
      refute dfa.accepting?("baba")
    end

    def test_graphviz_to_dfa
      graphviz_string = <<~S.chomp
      digraph finite_state_machine {
        fontname="Helvetica,Arial,sans-serif"
        node [fontname="Helvetica,Arial,sans-serif"]
        edge [fontname="Helvetica,Arial,sans-serif"]
        rankdir=LR;
        node [shape = circle];
        A -> B [label = "0"];
        A -> A [label = "1"];
        B -> B [label = "0"];
        B -> B [label = "1"];
      }
      S

      rules = DFA.graphviz_to_dfa_rules(graphviz_string)
      dfa   = DFA.new(start_state: "A", accept_states: ["B"], rules: rules)

      assert dfa.accepting?("01")
      assert !dfa.accepting?("11")
    end

    def test_dfa_rules_to_graphviz
      graphviz_string = <<~S.chomp
      digraph finite_state_machine {
        fontname="Helvetica,Arial,sans-serif"
        node [fontname="Helvetica,Arial,sans-serif"]
        edge [fontname="Helvetica,Arial,sans-serif"]
        rankdir=LR;
        node [shape = circle];
        A -> B [label = "0"];
        A -> A [label = "1"];
        B -> B [label = "0"];
        B -> B [label = "1"];
      }
      S

      rules = {"A"=>{"0"=>"B", "1"=>"A"}, "B"=>{"0"=>"B", "1"=>"B"}}

      result = DFA.dfa_rules_to_graphviz(rules)

      assert_equal result, graphviz_string
    end
  end
end
