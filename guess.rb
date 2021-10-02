# frozen_string_literal: true

# stores guess information and feedback
class Guess
  attr_accessor :code, :feedback

  def initialize
    @code = %w[]
    @feedback = []
  end
end
