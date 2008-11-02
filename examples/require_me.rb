class RequireMe
  def initialize( msg )
    @msg = msg
    puts "RequireMe initialized"
  end

  def foo
    puts @msg
  end
end
