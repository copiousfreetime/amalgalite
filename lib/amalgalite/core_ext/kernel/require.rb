module Kernel
  alias :original_require :require
  #
  # hook into the system 'require' to allow for required text or blobs from an
  # amalgalite database.  
  #
  def require( filename )
    found = Amalgalite::Requires.require( filename )
    unless found
      found = original_require( filename )
    end
    return found
  end
end
