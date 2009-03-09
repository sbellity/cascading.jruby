module Cascading
  module PipeHelpers
    def cut
      raise 'Not implemented yet'
    end 

    def tokenize
      raise 'Not implemented yet'
    end

    def debug(*args)
      options = args.extract_options!
      print_fields = options[:print_fields] || true
      parameters = [print_fields].compact
      each(all_fields, :filter => Java::CascadingOperation::Debug.new(*parameters))
    end

    def count(*args)
      options = args.extract_options!
      fields = args[0] || last_grouping_fields
      into = options[:into]      
      output = options[:output] || all_fields
      every(fields, :aggregator=>count_function(into), :output => output)
    end
    
    def average(*args)
      options = args.extract_options!
      fields = args[0] || last_grouping_fields
      into = options[:into] 
      output = options[:output] || all_fields
      every(fields, :aggregator=>average_function(into), :output => output)
    end

    def split(*args)
      options = args.extract_options!
      fields = options[:into] || args[1]
      pattern = options[:pattern] || /[.,]*\s+/
      output = options[:output] || all_fields

      each(args[0], :filter => regex_splitter(fields, :pattern => pattern), :output=>output)
    end


    def format_date(*args)
      options = args.extract_options!
      field = options[:into] || "#{args[0]}_formatted"
      output = options[:output] || all_fields
      pattern = options[:pattern] || "yyyy/MM/dd"

      each args, :function => date_formatter(field, pattern), :output => output
    end

    def replace(*args)
      options = args.extract_options!

      pattern = options[:pattern] || args[1]
      replacement = options[:replacement] || args[2]
      into = options[:into] || "#{args[0]}_replaced"
      output = options[:output] || all_fields

      each args[0], :function => regex_replace(into, pattern, replacement), :output => output
    end

    def filter_by_expression(*args)
      options = args.extract_options!
      from = options[:from] || all_fields

      each from, :filter => expression_filter(:expression => args[0])
    end

    def eval_expression(*args)
      options = args.extract_options!

      into = options[:into]
      from = options[:from] || all_fields

      output = options[:output] || all_fields

      each from, :function => expression_function(into, :expression => args[0]), :output=>output
    end
    
    def distinct(*fields)
      group_by(fields || all_fields)
      every all_fields, :aggregator=>Java::CascadingOperationAggregator::First.new, :output=>results_fields
    end
      
  end # module PipeHelpers
  
end # module Cascading