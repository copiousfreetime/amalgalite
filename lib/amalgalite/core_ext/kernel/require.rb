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
      puts "#{"--"}> am loading #{filename}"
      loaded = Amalgalite::Requires.require( filename )
      puts "<#{"--"} am loaded #{filename} #{loaded}"
    rescue LoadError => le
      puts "load error from amalgalite : #{le}"
      puts "--> am original loading #{filename}"
      loaded = amalgalite_original_require( filename )
      puts "<-- am original loaded #{filename} #{loaded}"
    end
  end
end
