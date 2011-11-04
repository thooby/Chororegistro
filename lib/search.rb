module ActiveRecord
   class Base
     # Allow the user to set the default searchable fields
     def self.searches_on(*args)
       if not args.empty? and args.first != :all
         @searchable_fields = args.collect { |f| f.to_s }
       end
     end

     # Return the default set of fields to search on
     def self.searchable_fields(tables = nil, klass = self)
       # If the model has declared what it searches_on, then use that...
       return @searchable_fields unless @searchable_fields.nil?

       # ... otherwise, use all text/varchar fields as the default
       fields = []
       tables ||= []
       string_columns = klass.columns.select { |c| c.type == :text or
c.type == :string }
       fields = string_columns.collect { |c| klass.table_name + "." +
c.name }

       if not tables.empty?
         tables.each do |table|
           klass = eval table.to_s.classify
           fields += searchable_fields([], klass)
         end
       end

       return fields
     end

     # Search the movie database for the given parameters:
     #   text = a string to search for
     #   :only => an array of fields in which to search for the text;
     #     default is 'all text or string columns'
     #   :except => an array of fields to exclude from the
     #     default searchable columns
     #   :case => :sensitive or :insensitive
     #   :include => an array of tables to include in the joins.
     #     Fields that have searchable text will automatically be
     #     included in the default set of fields to search
     #   :join_include => an array of tables to include in the joins,
     #     but only for joining. (Searchable fields will not
     #     automatically be included.)
     #   :conditions => a string of additional conditions (constraints)
     #   :offset => paging offset (integer)
     #   :limit => number of rows to return (integer)
     def self.search(text = nil, options = {})
       options.assert_valid_keys(:only, :except, :case, :include,
                         :join_include, :conditions, :offset, :limit
                         )
       case_insensitive = true unless options[:case] == :sensitive

       # The fields to search (default is all text fields)
       fields = options[:only] || searchable_fields(options[:include])
       fields -= options[:except] if not options[:except].nil?

       # Now build the SQL for the search if there is text to search for
       condition_list = []
       unless text.nil?
         text_condition = if case_insensitive
           fields.collect do |f|
              #"#{f} = '#{text}'"
              #"translate(#{f},'zca�B','ss') = translate('#{text}','zca�O','ss') "
              "upper(translate(#{f},'zcaeiou�����','ss')) = upper(translate('#{text}','zcaeiou�����','ss'))  "

             #"dmetaphone_alt((#{f})) ~ dmetaphone_alt('%#{text.upcase}%')" 
             # "metaphone((#{f}),8) ~ metaphone('%#{text.upcase}%',8)" 
             #"UPPER(#{f}) LIKE '%#{text.upcase}%'" 
           end.join " OR " 
         else
           fields.collect { |f| "#{f} LIKE '%#{text}%'" }.join " OR " 
         end

         # Add the text search term's SQL to the conditions string unless
         # the text was nil to begin with.
         condition_list << "(" + text_condition + ")" 
       end
       condition_list << "#{sanitize_sql(options[:conditions])}" if options[:conditions]
       conditions = condition_list.join " AND " 
       conditions = nil if conditions.empty?

       includes = (options[:include] || []) +
         (options[:join_include] || [])
       includes = nil if includes.size == 0

       find :all, :include => includes, :conditions => conditions,
            :offset => options[:offset], :limit => options[:limit]
     end
   end
end

