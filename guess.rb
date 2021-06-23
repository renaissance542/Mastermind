# frozen_string_literal: true

# stores guess information and feedback
class Guess
  attr_accessor :code, :feedback, :unmatched_guesses, :unmatched_secrets

  def initialize
    @code = %w[]
    @feedback = []
    @unmatched_guesses = [0, 1, 2, 3]
    @unmatched_secrets = [0, 1, 2, 3]
  end
end
