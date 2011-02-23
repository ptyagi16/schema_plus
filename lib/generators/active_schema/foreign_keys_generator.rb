require 'rails/generators'
require 'rails/generators/active_record'

module ActiveSchema
  module Generators
    class ForeignKeysGenerator < ::ActiveRecord::Generators::Base
      argument :name, :default => 'create_foreign_keys'

      def self.source_root
        File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def create_migration_file
        set_local_assigns!
        migration_template 'create_foreign_keys.rb', "db/migrate/#{file_name}"
      end

      protected
      attr_reader :foreign_keys

      def set_local_assigns!
        @foreign_keys = determine_foreign_keys
      end

      def determine_foreign_keys
        foreign_keys = []
        connection = ::ActiveRecord::Base.connection
        connection.tables.each do |table_name|
          connection.columns(table_name).each do |column|
            references = ::ActiveRecord::Migration.get_references(table_name, column.name)
            foreign_keys << ::ActiveSchema::ActiveRecord::ConnectionAdapters::ForeignKeyDefinition.new(nil, table_name, column.name, references.first, references.last) if references
          end
        end
        foreign_keys
      end
    end
  end
end