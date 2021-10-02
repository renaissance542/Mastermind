# frozen_string_literal: true

# generate and keep code, and give guess feedback
class SecretCode
  attr_accessor :possible_colors, :secret_code

  def initialize
    @possible_colors = %w[Red Blue White Green Yellow Black]
    @secret_code = generate_code
    @unmatched_guesses = []
    @unmatched_secrets = []
  end

  def submit_guess(guess)
    @unmatched_guesses = [0, 1, 2, 3]
    @unmatched_secrets = [0, 1, 2, 3]
    fill_red_pegs(guess)
    fill_white_pegs(guess)
    guess
  end

  private

  def generate_code
    code = []
    4.times { code.push(@possible_colors   .sample) }
    code
  end

  def fill_red_pegs(guess)
    0.upto(3) do |i|
      next unless guess.code[i] == @secret_code[i]

      guess.feedback.push('Red')
      # any guess that got 'Red' feedback
      # cannot recieve additional feedback
      @unmatched_guesses.delete(i)
      @unmatched_secrets.delete(i)
    end
  end

  def fill_white_pegs(guess)
    @unmatched_guesses.each do |i|
      @unmatched_secrets.each do |j|
        next unless guess.code[i] == @secret_code[j]

        guess.feedback.push('White')
        # only one feedback per peg
        @unmatched_secrets.delete(j)
        break
      end
    end
  end
end
