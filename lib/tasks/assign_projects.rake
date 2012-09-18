task :assign_projects => :environment do |t, args|
  ActiveRecord::Base.transaction do
    # Don't worry about runtime since problem size is fairly small
    # Do easy assignments first, where only one group picked a project first
    #groups = Group.all
    #assigned_groups = []
    #groups.each do |group|
    #  first_pref = group.project_preferences.find_by_level(1)
    #  if first_pref.nil?
    #    puts "Warning: Group #{group.id} has no first preference"
    #    next
    #  end

    #  # Check whether any other group
    #end

    # Stable marriage
    groups = Group.all

    # First filter out groups with self-proposed projects
    self_proposed = []
    delete_list = []
    groups.each do |group|
      first_pref = group.project_preferences.find_by_level(1)
      if first_pref.nil?
        puts "Warning: Group #{group.id} has no first preference"
        delete_list << group
        next
      end
      if first_pref.project.title == "Self-proposed Project"
        group.assigned_project = first_pref.project
        group.save!
        delete_list << group
      end
    end

    groups = groups - delete_list

    # Delete exceptions, aka "dibs"

    # Research Match group
    g = Group.find(20)
    p = Project.find(23)
    g.assigned_project = p
    g.save!
    p.project_preferences.destroy_all
    p.save!
    ProjectPreference.create!(project: p, group: g, level: 1)
    groups.delete g

    # Question Bank group
    g = Group.find(22)
    p = Project.find(22)
    g.assigned_project = p
    g.save!
    p.project_preferences.destroy_all
    p.save!
    ProjectPreference.create!(project: p, group: g, level: 1)
    groups.delete g

    # Stable marriage on remaining groups
    # I think this ends up being biased in favor of the first group who is assigned
    # Unbias it through randomness?
    free_list = groups.dup
    until free_list.empty?
      group = free_list.shuffle!.pop
      first_pref = group.project_preferences.order("level ASC").first

      if first_pref.nil?
        raise "Out of project possibilities"
      end

      project = first_pref.project
      if project.assigned_group.nil?
        group.assigned_project = project
        group.save!
        project.assigned_group = group
        project.save!
      else
        rival = project.assigned_group
        rival_pref = rival.project_preferences.find_by_project_id(project.id)
        if first_pref.level < rival_pref.level
          group.assigned_project = project
          group.save!
          project.assigned_group = group
          project.save!
          rival.assigned_project = nil
          rival.project_preferences.delete rival_pref
          rival.save!
          free_list.push rival
        else
          group.project_preferences.delete first_pref
          group.save!
          free_list.push group
        end
      end
    end

    histogram = Hash.new(0)
    Group.all.each do |g|
      begin
        #puts "#{g.id}: #{g.students.map{|s| "#{s.first_name} #{s.last_name}"}} #{g.assigned_project.title}"
        print "#{g.id}: #{g.assigned_project.title} "
        puts "(choice #{g.project_preferences.find_by_project_id(g.assigned_project.id).level})"
        histogram[g.project_preferences.find_by_project_id(g.assigned_project.id).level] += 1
      rescue
        puts "Error"
      end
    end
    puts histogram.inspect

    raise "Abort transaction"
  end
end
