module Kernel
  alias :amalgalite_original_require :require
  #
  # hook into the system 'require' to allow for required text or blobs from an
  # amalgalite database.  
  #
  def require( filename )
    found = Amalgalite::Requires.require( filename )
    if not found and not $".include?( filename ) and not Amalgalite::Requires.requiring.include?( filename ) then
      found = amalgalite_original_require( filename )
    end
    return found
  end
end
