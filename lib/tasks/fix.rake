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
end
