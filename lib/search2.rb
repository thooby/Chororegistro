module ActiveRecord
   class Base
     # Allow the user to set the default searchable fields
     def self.search2es_on(*args)
       if not args.empty? and args.first != :all
         @searchable_fields2 = args.collect { |f| f.to_s }
       end
     end

     # Return the default set of fields to search2 on
     def self.searchable_fields2(tables = nil, klass = self)
       # If the model has declared what it search2es_on, then use that...
       return @searchable_fields2 unless @searchable_fields2.nil?

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
           fields += searchable_fields2([], klass)
         end
       end

       return fields
     end

     # Search the movie database for the given parameters:
     #   text = a string to search2 for
     #   :only => an array of fields in which to search2 for the text;
     #     default is 'all text or string columns'
     #   :except => an array of fields to exclude from the
     #     default searchable columns
     #   :case => :sensitive or :insensitive
     #   :include => an array of tables to include in the joins.
     #     Fields that have searchable text will automatically be
     #     included in the default set of fields to search2
     #   :join_include => an array of tables to include in the joins,
     #     but only for joining. (Searchable fields will not
     #     automatically be included.)
     #   :conditions => a string of additional conditions (constraints)
     #   :offset => paging offset (integer)
     #   :limit => number of rows to return (integer)
     def self.search2(text = nil, options = {})
      options.assert_valid_keys(:only, :except, :case, :include,
                         :join_include, :conditions, :offset, :limit
                         )
       print text,'xxxxxxxxxxxxx'
       puts
       case_insensitive = true unless options[:case] == :sensitive

       # The fields to search2 (default is all text fields)
       fields = options[:only] || searchable_fields2(options[:include])
       fields -= options[:except] if not options[:except].nil?

       # Now build the SQL for the search2 if there is text to search2 for
       condition_list = []
       unless text.nil?
         text_condition = if case_insensitive
           text2=text.upcase
           fields.collect do |f|
            "upper(translate(#{f},'Ã¡Ã©Ã­Ã³ÃºÃ±','aeioun')) = upper(translate('#{text}','Ã¡Ã©Ã­Ã³ÃºÃ±','aeioun'))  "

             #UPPER(#{f}) LIKE '%#{text2}%'" 
           end.join " OR " 
         else
           fields.collect { |f| "#{f} LIKE '%#{text}%'" }.join " OR " 
         end

         # Add the text search2 term's SQL to the conditions string unless
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

