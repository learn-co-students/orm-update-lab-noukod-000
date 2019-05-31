require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
attr_accessor :name, :grade
attr_reader :id

def initialize(id=nil,name,grade)
  @id = id
  self.name = name
  self.grade = grade
end

def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =  <<-SQL
      DROP TABLE students
        SQL
    DB[:conn].execute(sql)
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

    def self.create(name,grade)
        student = Student.new(name,grade)
        student.save
        student
      end
      
      def self.new_from_db(row)
          new_student = self.new(row[0], row[1], row[2])
          new_student
        end

        def self.find_by_name(name)
          sql = <<-SQL
            select * from students where name = ?
          SQL

          DB[:conn].execute(sql, name).map do |student|
            self.new_from_db(student)
          end.first
        end

end
