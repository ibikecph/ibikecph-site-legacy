#module ActsAsTaggableOn::Taggable
#  module Related
#    module InstanceMethods
#      def matching_contexts_for_with_rails3(search_context, result_context, klass, options = {})
#        tags_to_find = tags_on(search_context).collect { |t| t.name }
#
#        exclude_self = "#{klass.table_name}.#{klass.primary_key} != #{id} AND" if [self.class.base_class, self.class].include? klass
#
#        group_columns = ActsAsTaggableOn::Tag.using_postgresql? ? grouped_column_names_for(klass) : "#{klass.table_name}.#{klass.primary_key}"
#
#        klass.scoped({ :select     => "#{klass.table_name}.*, COUNT(#{ActsAsTaggableOn::Tag.table_name}.#{ActsAsTaggableOn::Tag.primary_key}) AS count_all",
#                       :from       => "#{klass.table_name}, #{ActsAsTaggableOn::Tag.table_name}, #{ActsAsTaggableOn::Tagging.table_name}",
#                       :conditions => ["#{exclude_self} #{klass.table_name}.#{klass.primary_key} = #{ActsAsTaggableOn::Tagging.table_name}.taggable_id AND #{ActsAsTaggableOn::Tagging.table_name}.taggable_type = '#{klass.base_class.to_s}' AND #{ActsAsTaggableOn::Tagging.table_name}.tag_id = #{ActsAsTaggableOn::Tag.table_name}.#{ActsAsTaggableOn::Tag.primary_key} AND #{ActsAsTaggableOn::Tag.table_name}.name IN (?) AND #{ActsAsTaggableOn::Tagging.table_name}.context = ?", tags_to_find, result_context],
#                       :group      => group_columns,
#                       :order      => "count_all DESC" }.update(options))
#      end
#
#      alias_method_chain :matching_contexts_for, :rails3
#
#      def related_tags_for_with_rails3(context, klass, options = {})
#        tags_to_find = tags_on(context).collect { |t| t.name }
#
#        exclude_self = "#{klass.table_name}.#{klass.primary_key} != #{id} AND" if [self.class.base_class, self.class].include? klass
#
#        group_columns = ActsAsTaggableOn::Tag.using_postgresql? ? grouped_column_names_for(klass) : "#{klass.table_name}.#{klass.primary_key}"
#
#        klass.scoped({ :select     => "#{klass.table_name}.*, COUNT(#{ActsAsTaggableOn::Tag.table_name}.#{ActsAsTaggableOn::Tag.primary_key}) AS count_all",
#                       :from       => "#{klass.table_name}, #{ActsAsTaggableOn::Tag.table_name}, #{ActsAsTaggableOn::Tagging.table_name}",
#                       :conditions => ["#{exclude_self} #{klass.table_name}.#{klass.primary_key} = #{ActsAsTaggableOn::Tagging.table_name}.taggable_id AND #{ActsAsTaggableOn::Tagging.table_name}.taggable_type = '#{klass.base_class.to_s}' AND #{ActsAsTaggableOn::Tagging.table_name}.tag_id = #{ActsAsTaggableOn::Tag.table_name}.#{ActsAsTaggableOn::Tag.primary_key} AND #{ActsAsTaggableOn::Tag.table_name}.name IN (?)", tags_to_find],
#                       :group      => group_columns,
#                       :order      => "count_all DESC" }.update(options))
#      end
#
#      alias_method_chain :related_tags_for, :rails3
#    end
#  end
#end#