require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade
  
  def initialize(id = nil,name,grade)
    @id =id
    @name = name
    @grade = grade
  end
  
  # ruby => database
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)
      SQL
      DB[:conn].execute(sql)
  end
  
  # ruby => database
  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
      SQL
      DB[:conn].execute(sql)
  end
  
  # ruby => database
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  
  # ruby => database
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  
  
  # ruby => database
  # no mass assignment in this case (name:, :grade)
  def self.create(name, grade)
    stud = Student.new(name, grade)
    stud.save
    stud
  end
  
  # database => ruby
  # take row convert to object
  def self.new_from_db(row)
    id = row[0]
    name =  row[1]
    grade = row[2]
    Student.new(id,name,grade)   # custom constructor
  end
  
  # database => ruby
  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  
end
