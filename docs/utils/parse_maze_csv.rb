require 'csv'
require 'json'

# read IO stream from file
#
# parse data as objects(column names as keys)
#
# ready to output as csv, or spreadsheet types

meta_keys_map = {
  # original column_name --> exported column name
  :hasKids => 'Has kids',
  :education => 'Education',
  :year => 'Birth year',
  :sex => 'gender',
  :employmentStatus => 'Employment status',
  :maritalStatus => 'Marital status',
  :technicalProficiency => 'Technical proficiency'
}


new_array = []

CSV.read("./hyllo v1 usability testers meta data.csv").each_with_index do |row, index|
  if index > 0
    new_row = [];
    new_row.push(row[0])  # tester id
    new_row.push(row[4]) # lang
    meta_object = JSON.parse(row[-1]) # parse meta column as object
    meta_keys_map.each do |key, value|
      new_row.push(meta_object[key.to_s])
    end

    new_array.push(new_row)
  end
end

new_column_names = ['Tester Id', 'Language'].push(meta_keys_map.values).flatten
new_array.prepend(new_column_names)
print new_array


CSV.open("./hyllo_parsed_tester_data.csv", "wb") do |csv|
  new_array.each { |row| csv << row }
end