# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Admin.create({ :email => 'admin@cs169.berkeley.edu', :password => 'password', :password_confirmation => 'password'})


iter_1_1_deadline = Date.parse('14-10-2012').to_datetime + 1.day - 1.second
iter_1_2_deadline = Date.parse('21-10-2012').to_datetime + 1.day - 1.second
iter_2_1_deadline = Date.parse('28-10-2012').to_datetime + 1.day - 1.second
iter_2_2_deadline = Date.parse('04-11-2012').to_datetime + 1.day - 1.second
iter_3_1_deadline = Date.parse('11-11-2012').to_datetime + 1.day - 1.second
iter_3_2_deadline = Date.parse('18-11-2012').to_datetime + 1.day - 1.second
iter_4_1_deadline = Date.parse('28-11-2012').to_datetime + 1.day - 1.second
iter_4_2_deadline = Date.parse('05-12-2012').to_datetime + 1.day - 1.second

Iteration.create([
  { :name => 'Iteration 1-1', :due_date => iter_1_1_deadline },
  { :name => 'Iteration 1-2', :due_date => iter_1_2_deadline },
  { :name => 'Iteration 2-1', :due_date => iter_2_1_deadline },
  { :name => 'Iteration 2-2', :due_date => iter_2_2_deadline },
  { :name => 'Iteration 3-1', :due_date => iter_3_1_deadline },
  { :name => 'Iteration 3-2', :due_date => iter_3_2_deadline },
  { :name => 'Iteration 4-1', :due_date => iter_4_1_deadline },
  { :name => 'Iteration 4-2', :due_date => iter_4_2_deadline }
])

