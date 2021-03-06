class Clint

  def initialize(options={})
    reset
    @strict = !!options[:strict]
  end

  def usage
    if block_given?
      @usage = Proc.new
    else
      @usage.call if @usage.respond_to? :call
    end
  end

  def help
    if block_given?
      @help = Proc.new
    else
      usage
      @help.call if @help.respond_to? :call
    end
  end

  # Reset the list of valid options and aliases.
  def reset
    @options, @aliases = {}, {}
  end

  # Add new valid options and aliases with either classes to be constructed
  # or default values (from which classes are inferred).  This returns
  # @options and thus works as an attr_reader with no arguments.
  def options(options={})
    options.each do |option, default|
      option = option.to_sym
      if Symbol == default.class
        @aliases[option] = default
      else
        if Class == default.class
          if default.respond_to? :new
            begin
              @options[option] = default.new
            rescue ArgumentError
              @options[option] = default.new(nil)
            end
          else
            begin
              @options[option] = default()
            rescue ArgumentError
              @options[option] = default(nil)
            end
          end
        else
          @options[option] = default
        end
      end
    end
    @options
  end

  attr_reader :aliases

  # Parse arguments, saving options in @options and leaving everything else
  # in @args.
  def parse(args=nil)
    args = @args if args.nil?
    i = 0
    while args.length > i do

      # Skip anything not structured like an option.
      option, value = case args[i]
      when /^-([^-=\s]+)$/
        args.delete_at i
        $1.reverse.each_char { |c| args.insert i, "-#{c}" }
        [$1[0, 1].to_sym, nil]
      when /^-([^-=\s])\s*(.+)$/
        [$1.to_sym, $2]
      when /^--([^=\s]+)$/
        [$1.to_sym, nil]
      when /^--([^=\s]+)(?:=|\s+)(.+)?$/
        [$1.to_sym, $2]
      else
        i += 1
        next
      end

      # Follow aliases through to a real option.
      option = @aliases[option] while @aliases[option]

      # Skip unknown options unless we're in strict mode.
      if @options[option].nil?
        if @strict
          usage
          exit 1
        end
        i += 1
        next
      end

      # Handle boolean options.
      if [TrueClass, FalseClass].include? @options[option].class
        unless value.nil?
          usage
          exit 1
        end
        args.delete_at i
        @options[option] = !@options[option]

      # Handle options with values.  The call to new below may raise
      # NoMethodError but this is allowed to surface so it's noticed
      # during development.
      else
        args.delete_at i
        value = args.delete_at(i) if value.nil?
        if value.nil?
          usage
          exit 1
        end
        @options[option] = @options[option].class.new(value)

      end
    end
    @args = args
  end

  # Pass options and arguments however possible to the given callable, which
  # could be a Proc or just an object that responds to the method call.
  def dispatch(callable)
    arity = begin
      callable.arity
    rescue NoMethodError
      callable.method(:call).arity
    end
    if @args.length == arity
      callable.call(*@args)
    elsif -@args.length - 1 == arity
      callable.call(*(@args + [@options]))
    else
      dispatch callable.new
      exit 0
    end
  rescue Exception => e
    raise e if SystemExit == e.class || SignalException == e.class
    usage
    exit 1
  end

  # Treat the first non-option argument as a subcommand in the given class.
  # If a suitable class method is found, it is called with all remaining
  # arguments, including @options if we can get away with it.  Otherwise,
  # an instance is constructed with the next non-option argument and the
  # subcommand is sent to the instance with the remaining non-option
  # arguments.
  def subcommand(klass)

    # Find the subcommand.
    if 1 > @args.length
      usage
      exit 1
    end
    subcommand = @args.shift.to_sym

    # Give the caller the opportunity to declare more options.
    yield subcommand if block_given?

    # Execute the subcommand as a class method.
    if klass.singleton_methods(false).include? subcommand.to_s
      arity = klass.method(subcommand).arity
      if @args.length == arity || -@args.length - 1 == arity
        begin
          klass.send subcommand, *(@args + [@options])
        rescue ArgumentError
          klass.send subcommand, *@args
        end
        exit 0
      end
    end

    # Execute the subcommand as an instance method.
    arity = klass.allocate.method(:initialize).arity
    if 0 > arity
      arity = arity.abs - 1
    end
    if arity > @args.length
      usage
      exit 1
    end
    instance = klass.new(*@args.slice!(0, arity))
    if instance.public_methods(false).any? {|m| m == subcommand || m == subcommand.to_s }
      arity = instance.method(subcommand).arity
      if @args.length != arity && -@args.length - 1 != arity
        usage
        exit 1
      end
      begin
        instance.send subcommand, *(@args + [@options])
      rescue ArgumentError
        instance.send subcommand, *@args
      end
      exit 0
    end

    # No suitable class or instance method was found.
    usage
    exit 1

  end

end
