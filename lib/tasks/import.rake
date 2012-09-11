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
        CSV.foreach(args[:csv_file], encoding: "UTF-8") do |row|
          if skip_first
            headers = row
            skip_first = false
            next
          end

          next if row[1].blank? # skip blank rows and fake title rows

          title = row[headers.index("Full Organization Name")] # This is actually just the orginazition name
          location = row[headers.index("Organization Address")]
          short_description = row[headers.index("In one sentence, please explicitly summarize the goals of the project.")]
          description = ["Mission Statement",
                         "What current problems does your organization face? Which of these issues could be helped with web-based software?",
                         "What type of web-based software could benefit your organization?",
                         "Please provide a two-paragraph description of the software that would most benefit your organization."].map do |col|
            datum = row[headers.index(col)]
            if datum.blank?
              ""
            else
              col + "\n\n" + datum
            end
          end.join("\n\n")

          Project.create! title: title, description: description, short_description: short_description, location: location
        end
      end

    end
  end
end
