require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id ,:name,:grade
  attr_reader

  def initialize(name=nil,grade=nil,id=nil)
    @name=name
    @grade=grade
    @id=id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS students(id INTEGER PRIMARY KEY,name TEXT,grade TEXT) ")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def save
    if(self.id)
      self.update
    else
      sql=<<-SQL
        INSERT INTO students(name,grade)
        VALUES(?,?)
      SQL

      DB[:conn].execute(sql,self.name,self.grade)
      @id=DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end

  end

  def update
    sql="UPDATE students SET name=?,grade=? WHERE id=?"
    DB[:conn].execute(sql,self.name,self.grade,self.id)
  end

  def self.create(name,grade)
    student=Student.new(name,grade)
    student.save
  end


    def self.new_from_db(row)
            new_student = self.new
            new_student.id = row[0]
            new_student.name =  row[1]
            new_student.grade = row[2]
            new_student
    end

  def self.find_by_name(name)
    sql=<<-SQL
      SELECT * FROM students
      WHERE name=?
    SQL

    row=DB[:conn].execute(sql,name).first
    Student.new(row[1],row[2],row[0])
  end
end
