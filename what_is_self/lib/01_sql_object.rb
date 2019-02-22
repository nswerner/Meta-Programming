require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  # def initialize(parameters = {})
  #   columns = SQLObject.columns
  #   parameters.each do |attr_name, value|
  #     unless columns.include?(attr_name)
  #       raise "unknown attribute '#{attr_name}''"
  #     end
  #   end
    
  # end
  
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    @columns[0].map(&:to_sym)
  end

  def self.finalize!
    columns = self.columns

    columns.each do |column|
        define_method(column) { self.attributes[column] }
        define_method("#{column}=") { |val| self.attributes[column] = val }
    end
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end
  
  def self.all
    # self.parse_all(
    rows = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    # .parse_all 
    #)
    # self.parse_all(@rows)
    parse_all(rows)
    # parse_all(rows)
  end

# def self.parse_all(results = self.all)
  def self.parse_all(results)
    object_array = []

    results.each do |result|
      object_array << self.new(result)
    end

    object_array
  end

  def self.find(id)
    # debugger
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL
    
    unless result.empty?
      return self.new(*result)
    end

    nil
  end
  # end

  def initialize(parameters = {})

    parameters.each do |attr_name, value|
      attr_sym = attr_name.to_sym
      # debugger
      unless self.class.columns.include?(attr_sym)
        raise "unknown attribute '#{attr_name}'"
      end

      self.send("#{attr_name}=", value)
      # self.class.finalize!
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
