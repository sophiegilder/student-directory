# ````
# global variables etc
# ````
@students = []

require 'date'
@months = Date::MONTHNAMES

require 'csv'

@pronoun = {
  "male" => {subject: "he", verb: "is", possessive: "his"},
  "female" => {subject: "she", verb: "is", possessive: "her"},
  "neutral" => {subject: "they", verb: "are", possessive: "their"}
}

# ````
# menu methods
# ````

def interactive_menu
  loop do
    print_menu
    process(STDIN.gets.chomp)
  end
end

def print_menu
  blank_line
  puts "What would you like to do?"
  blank_line
  puts "1. Input the students"
  puts "2. Show the students"
  puts "3. Save students to file"
  puts "4. Load students from file"
  puts "5. Search students by cohort"
  puts "6. View students by cohort"
  puts "7. Remove student"
  puts "8. Edit student details"
  puts "9. Exit"
end

def process(selection)
  case selection
  when "1"
    input_students
    puts "input complete"
  when "2"
    show_students
  when "3"
    save_students
  when "4"
    load_students
  when "5"
    print_by_cohort 
  when "6"
    print_by_cohort_all
  when "7"
    remove_student
  when "8"
    edit_student
  when "9"
    exit_command
  else
    puts "Please enter a number between 1 and 9..."
  end
end

def show_students
  print_header
  print_students if @students.count > 0
  blank_line
  @students.empty? ? print_footer_no_students : print_footer
  blank_line
end

def save_students(filename = "students.csv")
  # check if they want to save or save as
  puts "You are about to save to #{filename}"
  puts "Hit enter to continue or type any key followed by enter to save to another / new file"
  input = gets.chomp
  filename = save_or_load_new if !input.empty?
  #open file for writing
  CSV.open(filename, "w") do |file|
    #iterate over students array
    @students.each do |student|
      # push each line directly to CSV
      file << [student[:name], student[:cohort], student[:gender], student[:height], student[:hobbies].join(",")]
    end
  end 
  puts "save to #{filename} complete"
end

def load_students(filename = "students.csv")
  # check this is the file they want to open
  puts "You are about to open our default file: #{filename}"
  puts "Hit enter to continue or type any letter followed by enter to open a different file"
  input = gets.chomp.downcase
  filename = save_or_load_new if !input.empty?
  # open file for reading
  CSV.foreach(filename) do |file|
    name, cohort, gender, height = file[0..3]
    hobbies = file[4].split(",")
    push_to_students(name, cohort, gender, height, hobbies)
  end
  print_load_success_text(filename)
end

def print_by_cohort #user enters the cohort they would like to see
  puts "Which cohort would you like to see?"
  #validation - user input matches a valid month
  while true do
    cohort = STDIN.gets.chomp.capitalize
    if @months.any? {|month| month == cohort}
      break
    elsif cohort == "Quit"
      return
    else
      puts "That's not a valid entry, try again or type quit to cancel operation"
    end
  end
  #creating a new array with just names of student in the selected cohort
  result = @students.select { |student| student[:cohort] == cohort }
  #print names, or error message
  if result.empty? 
    puts "There are no students enrolled on this cohort"
  else
    result.each { |student| puts student[:name] }
  end
end

def print_by_cohort_all #shows all student names split by cohort
  cohorts = @students.map { |student| student[:cohort] } .uniq
  cohorts.each do |month|
    puts month
    @students.each {|student| puts student[:name] if month == student[:cohort]}
    blank_line
  end
end

def remove_student
  result = find_index_of_student_by_name
  return if result == "Quit"
  puts "#{@students[result][:name]} deleted."
  @students.delete_at(result)
end

def edit_student
  student = find_index_of_student_by_name
  return if student == "Quit"
  puts "Which category would you like to edit? name, cohort, gender, height, hobbies"
  category = gets.chomp.downcase.to_sym
  if category == :hobbies
    puts "Current #{category}: #{@students[student][category].join(", ")}."
  else 
    puts puts "Current #{category}: #{@students[student][category]}."
  end
  puts "Please enter the updated details"
  new_data = category_selector(category)
  @students[student][category] = new_data
  puts "#{@students[student][:name]} updated"
end

def exit_command
  puts "Save changes before quitting? (y/n)"
  while true do
    input = gets[0].downcase
    case input
    when "y"
      save_students
      puts "bye!"
      exit
    when "n"
      puts "bye!"
      exit
    else 
      puts "enter yes or no"
    end
  end
end


# ````
# functionality methods
# ````

def input_students
  while true do
    puts "Enter next student name or press return twice to exit"
    name =  set_name
    break if name.empty?

    # assigning centre through set_gender method
    puts "Please enter their gender (M/F/NB)"
    gender = set_gender

    puts "Which cohort #{@pronoun[gender][:verb]} #{@pronoun[gender][:subject]} on?"
    puts "leave blank if they are in the current month's cohort"
    cohort = set_cohort

    puts "Please enter #{@pronoun[gender][:possessive]} height in cm"
    height = set_height

    puts "Please enter #{@pronoun[gender][:possessive]} hobbies, press return twice when done"
    hobbies = set_hobbies

    push_to_students(name, cohort, gender, height, hobbies)
    student_input_count
  end
end

def push_to_students(name, cohort, gender, height, hobbies)
  @students << {name: name, cohort: cohort, gender: gender, height: height.to_i, hobbies: hobbies}
end

def set_name
  name = STDIN.gets.chomp.split(" ").map!{|x| x.capitalize}.join(" ") #getting the name and ensuring each word is capitalized
  name
end

def set_gender
  gender = STDIN.gets.delete("\n").upcase # using an alternative to chomp for test
  #checking that input matches validation, using neutral as default
  case gender 
  when "M"
    gender = "male"
  when "F"
    gender = "female"
  else
    gender = "neutral"
  end
  gender
end

def set_cohort
  while true do
    cohort = STDIN.gets.chomp.capitalize
    # using current month as default if no month entered
    cohort = @months[Time.now.month] if cohort.empty?
    #checking that input matches validation
    break if @months[1..12].any? { |month| month == cohort }
  end
  cohort
end

def set_height
  height = STDIN.gets.chomp
  height
end

def set_hobbies
  hobbies = []
  #allows input of multiple hobbies into an array
  while true do
    input = STDIN.gets.chomp.downcase
    !input.empty? ? hobbies << input : break
  end
  hobbies
end

def find_index_of_student_by_name
  student_index = nil
  while true do
    puts "Please enter the name of the student"
    input = STDIN.gets.chomp.split(" ").map!{|x| x.capitalize}.join(" ")
    return input if input == "Quit"
    @students.each_with_index { |student, index| student_index = index if student[:name] == input }
    if student_index != nil
      break
    else
      puts "There is no student called `#{input}` on our records. Please select one of the follow students"
      puts "or type `quit` to cancel operation"
      print_by_cohort_all
    end
  end
  student_index
end

def category_selector(category)
  case category
  when :name
    set_name
  when :cohort
    set_cohort
  when :gender
    set_gender
  when :height
    set_height.to_i
  when :hobbies
    set_hobbies
  end
end

def save_or_load_new
  puts "Enter file name"
  filename = STDIN.gets.chomp
  filename = "#{filename}.csv" if !filename.include?(".csv")
  filename
end

def try_load_students(filename = "students.csv")
  filename = ARGV.first unless ARGV.first.nil? # first argument from the command line
  if File.exist?(filename) # check file exists
    load_students(filename)
  else # if it doesn't exists
    puts "Sorry, #{filename} does not exist."
    exit
  end
end

# ````
# printing methods
# ````

def student_input_count
  text = "Now we have #{@students.count} student"
  #pluralises sentence if there are multiple students
  puts @students.count > 1 ? "#{text}s" : text
end

def print_students
  @students.each_with_index do |student, index| 
    gender = student[:gender]
    puts "#{index + 1}. #{student[:name]} (#{student[:cohort]} cohort)"
    #if they didn't enter anything, don't print height
    if student[:height] > 0
      puts " - #{@pronoun[gender][:subject].capitalize} #{@pronoun[gender][:verb]} #{student[:height]}cm tall"
    end
    # if they didn't enter anything, don't print hobbies
    if student[:hobbies] != []
      puts " - #{@pronoun[gender][:possessive].capitalize} hobbies: #{student[:hobbies].join(", ")}"
    end
  end
end

def print_load_success_text(filename)
  puts "Loaded #{@students.count} entries from #{filename}"
end

def print_header
  puts "The students of Villains Academy".center(50)
  puts "-------------".center(50)
end

def print_footer
  text =  "Overall, we have #{@students.count} great student."
  #different approach to addressing plural in the case of multiple students / no students
  puts @students.count > 1 ? text.insert(-2, "s") : text
end

def print_footer_no_students
  puts "We currently habve no students :("
end

def blank_line
  puts nil
end

try_load_students
interactive_menu