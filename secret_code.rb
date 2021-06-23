# generate and keep code, and give guess feedback
class SecretCode
  attr_accessor :colors, :secret_code

  def initialize
    @colors = %w[Red Blue White Green Yellow Black]
    @secret_code = generate_code
  end

  def guess_code(guess)
    fill_red_pegs(guess)
    fill_white_pegs(guess)
    guess
  end

  private

  def generate_code
    code = []
    4.times { code.push(@colors.sample) }
    code
  end

  def fill_red_pegs(guess)
    0.upto(3) do |i|
      if guess.code[i] == @secret_code[i]
        guess.feedback.push('Red')
        # any guess that got 'Red' feedback
        # cannot recieve additional feedback
        guess.unmatched_guesses.delete(i)
        guess.unmatched_secrets.delete(i)
      end
    end
  end

  def fill_white_pegs(guess)
    guess.unmatched_guesses.each do |i|
      guess.unmatched_secrets.each do |j|
        if guess.code[i] == @secret_code[j]
          guess.feedback.push('White')
          # only one feedback per peg
          guess.unmatched_secrets.delete(j)
          break
        end
      end
    end
  end
end
