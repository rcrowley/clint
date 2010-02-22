clint(7) -- Ruby command line argument parser
=============================================

## SYNOPSIS

	require 'clint'
	c = Clint.new
	c.usage do
	  $stderr.puts "Usage: #{File.basename(__FILE__)} [-h|--help]"
	end
	c.help do
	  $stderr.puts "  -h, --help\tshow this help message"
	end
	c.options :help => false, :h => :help
	c.parse ARGV
	if c.options[:help]
	  c.help
	  exit 1
	end
	c.subcommand Klass

## DESCRIPTION

Clint is an alternative Ruby command line argument parser that's very good for programs using the subcommand pattern familiar from `git`(1), `svn`(1), `apt-get`(8), and many others.  In addition, it separates option declarations from usage and help messages becuase the author feels like that's a better idea.

Clint options are declared by passing hash arguments to `Clint#options`.  The hash keys should be `Symbol`s.  If the value is also a `Symbol`, an alias is defined from the key to the value.  If the value is a `Class`, Clint attempts to find a default value for that class.  Otherwise, the value is treated as the default and the value's class will be used to construct type-accurate values from command line arguments.

`Clint#options` may be called repeatedly to declare extra options and aliases.  `Clint#reset` can be used at any time to clear all declared options and aliases.

`Clint#parse` may likewise be called repeatedly.  At the end of each invocation, it stores the remaining non-option arguments, meaning that arguments (for example, `ARGV`) must only be passed as a parameter to the first invocation.

`Clint#subcommand` may be called after `Clint#parse` to automatically handle the subcommand pattern as follows.  The first non-option argument is taken to be the subcommand, which must exist as a singleton or instance method of the class object passed to `Clint#subcommand`.  If a suitable class method is found, it is called with all remaining arguments, including a hash of the parsed options if we can get away with it.  Otherwise, an instance is constructed with the next non-option argument and the instance method is called with all remaining arguments, again including a hash of the parsed options if we can get away with it.

Due to limitations in the Ruby 1.8 grammar, all methods that could act as subcommands must not declare default argument values except `options={}` if desired.

## AUTHOR

Richard Crowley <r@rcrowley.org>

## SEE ALSO

The standard Ruby `OptionParser` class <http://ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html>.
