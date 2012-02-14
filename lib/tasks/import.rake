namespace :import do
  namespace :students do
    desc "Import students from a CSV file"
    task :from_csv, [:csv_file] => [:environment] do |t, args|
      require 'csv'
      skip_first = true

      ActiveRecord::Base.transaction do
        CSV.foreach(args[:csv_file]) do |row|
          if skip_first
            skip_first = false
            next
          end
          g = Group.create!
          row.each do |person|
            nick_name = nil
            if person =~ /\((.*)\)/
              nick_name = $1
              person.gsub!(/\(.*\)/, '')
            end
            first_name, last_name = person.split[0..-2].join(" "), person.split[-1].strip
            params = {first_name: first_name, last_name: last_name, nick_name: nick_name, group: g}
            Student.create!(params)
          end
        end
      end

    end
  end

  namespace :projects do
    desc "Import projects from a CSV file"
    task :from_csv_special, [:csv_file] => [:environment] do |t, args|
      require 'csv'
      skip_first = true
      headers = []

      ActiveRecord::Base.transaction do
        CSV.foreach(args[:csv_file]) do |row|
          if skip_first
            headers = row
            skip_first = false
            next
          end

          title = row[1] # This is actually just the orginazition name
          description = [headers[15], row[15], headers[16], row[16], headers[17], row[17], headers[18], row[18]].join("\n\n")

          Project.create! title: title, description: description
        end
      end

    end
  end
end
