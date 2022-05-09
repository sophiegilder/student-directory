# ````
# global variables etc
# ````
@students = []

$pronoun = {
  male: {subject: "he", verb: "is", possessive: "his"},
  female: {subject: "she", verb: "is", possessive: "her"},
  neutral: {subject: "they", verb: "are", possessive: "their"}
}

# ````
# menu methods
# ````

def interactive_menu
  loop do
    print_menu
    process(gets.chomp)
  end
end

def print_menu
  puts "1. Input the students"
  puts "2. Show the students"
  puts "3. Save students to file"
  puts "4. Load students from file"
  puts "9. Exit"
end

def show_students
  print_header
  print_students
  blank_line
  print_footer
end

def process(selection)
  case selection
  when "1"
    students = input_students
  when "2"
    show_students
  when "3"
    save_students
  when "4"
    load_students
  when "9"
    exit
  else
    puts "Please enter a number between 1 and 9..."
  end
end

def save_students
  #open file for writing
  file = File.open("students.csv", "w")
  #iterate over students array
  @students.each do |student|
    #converting hash into array
    student_data = [student[:name], student[:cohort], student[:gender], student[:height]]
    #converting array into string
    csv_line = student_data.join(",")
    file.puts(csv_line)
  end 
  file.close
end

def load_students
  # open file for reading
  file = File.open("students.csv", "r")
  # iterate over each line of the file
  file.readlines.each do |line|
    name, cohort, gender, height, hobbies = line.chomp.split(",")
    @students << {name: name, cohort: cohort.to_sym, gender: gender.to_sym, height: height.to_i}
  end
  file.close
end

# ````
# functionality methods
# ````

def input_students
  while true do
    puts "Enter next student name or press return twice to exit"
    name = gets.chomp.split(" ").map!{|x| x.capitalize}.join(" ") #getting the name and ensuring each word is capitalized
    break if name.empty?

    # assigning centre through set_gender method
    puts "Please enter their gender (M/F/NB)"
    gender = set_gender

    puts "Which cohort #{$pronoun[gender][:verb]} #{$pronoun[gender][:subject]} on?"
    cohort = set_cohort

    puts "Please enter #{$pronoun[gender][:possessive]} height in cm"
    height = gets.chomp.to_i #to_i deletes any additional characters such as "cm"

    #puts "Please enter #{$pronoun[gender][:possessive]} hobbies, press return twice when done"
    #hobbies = set_hobbies

    @students << {name: name, cohort: cohort, gender: gender, height: height} #hobbies: hobbies }
    
    student_input_count
  end
end

def set_gender
  gender = gets.delete("\n").upcase #using an alternative to chomp
  #checking that input matches validation, using neutral as default
  case gender 
  when "M"
    gender = :male
  when "F"
    gender = :female
  else
    gender = :neutral
  end
  gender
end

def set_cohort
  months = [:January, :February, :March, 
            :April, :May, :June, 
            :July, :August, :September, 
            :October, :November, :December] #validation
  while true do
    cohort = gets.chomp.capitalize.to_sym
    cohort = :November if cohort.empty?
    #checking that input matches validation
    break if months.any? { |month| month == cohort }
  end
  cohort
end

def set_hobbies
  hobbies = []
  #allows input of multiple hobbies into an array
  while true do
    input = gets.chomp.downcase
    !input.empty? ? hobbies << input : break
  end
  hobbies
end

def student_input_count
  text = "Now we have #{@students.count} student"
  #pluralises sentence if there are multiple students
  puts @students.count > 1 ? "#{text}s" : text
end

def print_students
  if @students.count > 0
    @students.each_with_index do |student, index| 
      gender = student[:gender]
      puts "#{index + 1}. #{student[:name]} (#{student[:cohort]} cohort)"
      #if they didn't enter anything, don't print height
      if student[:height] > 0
        puts " - #{$pronoun[gender][:subject].capitalize} #{$pronoun[gender][:verb]} #{student[:height]}cm tall"
      end
      #if they didn't enter anything, don't print hobbies
      #if student[:hobbies] != []
      #  puts " - #{$pronoun[gender][:possessive]} hobbies are #{student[:hobbies].join(", ")}."
      #end
    end
  end
end

def print_by_cohort #user enters the cohort they would like to see
  if @student.count > 0
    puts "Which cohort would you like to see?"
    months = [:January, :February, :March, :April, :May, :June, :July, :August, :September, :October, :November, :December]
    #validation - user input matches a valid month
    while true do
      cohort = gets.chomp.capitalize.to_sym
      break if months.any? {|month| month == cohort}
    end
    #creating a new array with just names of student in the selected cohort
    result = names.select { |student| student[:cohort] == cohort }
    #print names, or error message
    if result.empty? 
      puts "There are no students enrolled on this cohort"
    else
      result.each { |student| puts student[:name] }
    end
  end
end

def print_by_cohort_all #shows all student names split by cohort
  cohorts = {}
  @student.each do |student|
    cohort = student[:cohort]
    #checking if there is already a key for the cohort & creating a new one if not
    cohorts[cohort] = [] if cohorts[cohort] == nil
    #pushing student name to corresponding key
    cohorts[cohort] << student[:name]
  end
  cohorts.each do |key, value|
    puts key.to_s.center(20)
    puts value
    blank_line
  end
end

def print_header
  puts "The students of Villains Academy".center(50)
  puts "-------------".center(50)
end

def print_footer
  text =  "Overall, we have #{@students.count} great student."
  #different approach to addressing plural in the case of multiple students / no students
  if @students.count > 1
    puts text.insert(-2, "s")
  elsif @students.count == 0
    puts "We currently have no students :("
  else
    puts text
  end
end

def blank_line
  puts nil
end

interactive_menu