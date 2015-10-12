module MigrationDatabaseHelper
  def json_supported_database?
    (postgres? && postgres_correct_version?) || (mysql? && mysql_correct_version?)
  end

  def postgres?
    database_name == 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'
  end

  def postgres_correct_version?
    database_version > '9.3'
  end

  def mysql?
    database_name == 'ActiveRecord::ConnectionAdapters::MysqlAdapter'
  end

  def mysql_correct_version?
    database_version > '5.7.7'
  end

  def database_name
    ActiveRecord::Base.connection.class.name
  end

  def database_version
    ActiveRecord::Base.connection.select_value('SELECT VERSION()')
  end
end