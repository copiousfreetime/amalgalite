module Kernel
  # alias the original require away to use later
  alias :amalgalite_original_require :require

  #
  # hook into the system 'require' to allow for required text or blobs from an
  # amalgalite database.  
  #
  def require( filename )
    if Amalgalite::Requires.use_original_require? then
      loaded = amalgalite_original_require( filename )
    end
  rescue LoadError => load_error
    if load_error.message =~ /#{Regexp.escape filename}\z/ then
      loaded = Amalgalite::Requires.require( filename )
    else
      raise load_error
    end
  end

  private :require
  private :amalgalite_original_require
end
