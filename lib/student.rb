require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id
  def initialize(id=nil, name, grade)
    @id = id
    self.name = name
    self.grade = grade
  end

  def self.create_table
    sql = <<-SQL
                create table if not exists students (
                  id integer Primary Key,
                  name text,
                  grade text
                )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
                drop table if exists students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
        self.update
    else
      sql = <<-SQL
        Insert into students (name, grade) values (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("Select last_insert_rowid() from students").flatten.first
    end
  end

  def update
    sql = <<-SQL
      update students
        set name = ?,
           grade = ?
      where id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    s = self.new(name, grade)
    s.save
    s
  end

  def self.new_from_db(row)
    s = self.new(row[0], row[1], row[2])
    s
  end

  def self.find_by_name(name)
    sql = <<-SQL
                select * from students where name = ?
    SQL

    DB[:conn].execute(sql, name).map do |s|
      self.new_from_db(s)
    end.first
  end
end
