require 'optparse'
module Amalgalite
  #
  # Pack items into an amalgalite database.  This is exposed via the
  # commandline.  Because of the delicate nature of the require path, the global
  # constant LOADED_FEATURES_BEFORE is assumed to exist and has in it, the list
  # of items from $" that existed before Pack was required.
  #
  class Pack

    #
    # given a file, see if it can be found in the ruby load path, if so, return that
    # full path
    #
    def full_path_of( rb_file )
      $:.each do |load_path|
        guess = File.join( load_path, rb_file )
        return guess if File.exist?( guess )
      end
      return nil
    end

    #
    # Hash of the command line options
    #
    def options
      @options ||= {}
    end

    #
    # command line parser
    #
    def parser
      @parser ||= OptionParser.new do |op|
        op.banner  = "Usage: #{op.program_name} [options] <dbfile>"
        op.separator ""

        op.on("-f", "--force", "Force overwriting of an existing database") do |f|
          options[:force]= true
        end

        op.on("-d", "--directory DIR", "All files in the given directory will be packed") do |d|
          options[:directory] = d
        end

        op.on("-s", "--self", "pack amalgalite itself into the database") do |d|
          options[:self] = true
        end

        op.on("-t", "--table TABLE", "the table name to pack into") do |t|
          options[:table_name] = t
        end

        op.on("-z", "--compresss", "compress the file contents on storage") do |z|
          options[:compressed] = true
        end

      end
    end

    #
    # Determine the features loaded by an amalgalite requires
    #
    def amalgalite_loaded_features
    end

    # 
    # List of all files that should be required for use in the amalgalite
    # 
    def amalgalite_requires_list
    end

    # 
    # The list of loaded items after amalgalite is required
    #
    def run( argv = ARGV, env = ENV )
    end
  end
end
