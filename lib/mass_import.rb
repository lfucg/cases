require 'csv'
class MassImport
  attr_reader :bucket_id, :file

  def initialize(bucket_id, file)
    @bucket_id = bucket_id
    @file = file
  end

  def run
    db(build_sql)
  end

  private

  def build_sql
    sql = "DELETE FROM events WHERE bucket_id = #{bucket_id};"
    sql << "COPY events (bucket_id, row_checksum, description, datetime, address, hashed_address) from '#{file}' WITH (DELIMITER(','), QUOTE('\"'), FORMAT('csv'));"
    sql
  end

  def db(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

end
