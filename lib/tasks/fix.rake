namespace :fix do
  desc "Destroy all project preferences which have null pointers to groups or projects"
  task :project_preferences => :environment do |t, args|
    ProjectPreference.all.each do |pp|
      if pp.group.nil? or pp.project.nil?
        puts "Destroying #{pp.id}"
        pp.destroy
      end
    end
  end
  task :emails, [:csv_file] => :environment do |t, args|
    require 'csv'
    filename = args[:csv_file]
    if filename =~ /^https?:/
      require 'net/http'
      filetext = Net::HTTP.get(URI(filename))
    else
      filetext = File.open(filename){|f| f.read}
    end
    f = CSV.parse(filetext)
    students = f[2..-2] # skip first two header lines, last total line
    students = students.map do |s|
      {
        :last_name => s[1].split(',')[0].downcase,
        :first_name => s[1].split(',')[1].split[0].downcase,
        :full_first => s[1].split(',')[1].downcase,
        :email => s[2],
      }
    end
    def error(s)
      raise "ERROR #{s.full_name} (#{s.first_name})"
    end
    def set_email_and_save(s, hash)
      s.email = hash[:email]
      s.save!
    end
    Student.transaction do
      Student.all.each do |s|
        if s.first_name == "Yunrui"
          s.email = "viveezhang@berkeley.edu"
          s.save!
          next
        end
        set = students.select{|x| x[:last_name] == s.last_name.downcase}
        if set.size == 1
          set_email_and_save s, set.first and next
        elsif set.size <= 0
          set2 = students.select{|x| x[:last_name] =~ /#{s.last_name.downcase}/}
          if set2.size == 1
            set_email_and_save s, set2.first and next
          else
            error(s)
          end
        elsif set.size > 1
          set2 = set.select{|x| x[:first_name] == s.first_name.downcase}
          if set2.size == 1
            set_email_and_save s, set2.first and next
          else
            set3 = set.select{|x| x[:full_first] == s.first_name.downcase}
            if set3.size == 1
              set_email_and_save s, set3.first and next
            else
              set3 = set.select{|x| x[:first_name] == s.first_name.split[0].downcase}
              if set3.size == 1
                set_email_and_save s, set3.first and next
              else
                set3 = set.select{|x| x[:first_name].starts_with?(s.first_name.downcase)}
                if set3.size == 1
                  set_email_and_save s, set3.first and next
                else
                  set3 = set.select{|x| x[:full_first].gsub(/\s/, '') == s.first_name.downcase}
                  if set3.size == 1
                    set_email_and_save s, set3.first and next
                  else
                    if !s.nick_name.blank?
                      set3 = set.select{|x| x[:first_name] == s.nick_name.downcase}
                      if set3.size == 1
                        set_email_and_save s, set3.first and next
                      else
                        error(s)
                      end
                    else
                      error(s)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
