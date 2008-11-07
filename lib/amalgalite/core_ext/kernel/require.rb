module Kernel
  alias :amalgalite_original_require :require
  #
  # hook into the system 'require' to allow for required text or blobs from an
  # amalgalite database.  
  #
  def require( filename )
    loaded = false
    if $".include?( filename ) then
      return loaded
    end
    begin 
      loaded = Amalgalite::Requires.require( filename )
    rescue LoadError => le
      puts "failed to load #{le} from db"
      loaded = amalgalite_original_require( filename )
    end
    return loaded
  end
end
