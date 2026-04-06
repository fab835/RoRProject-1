class DefaultError < StandardError
  attr_reader :type, :errors

  def initialize(errors, type = :internal_error)
    @type = type
    @errors = errors
    super("System Error")
  end
end