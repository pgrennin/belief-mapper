
require 'faker'

belief = Belief.new

File.open( 'phrontisteryisms.txt' ).each_with_index do |line, index|
  if index.even?
    belief.name = line.chomp
  else
    belief.definition = line.chomp
    belief.save!
    belief = Belief.new
  end
end

10.times do
  User.create!(:email => Faker::Internet.email, :password => 'password', :password_confirmation => 'password')
end

User.all.each do |user|
    rand(10..20).times do
    belief = Belief.all.sample
    user.beliefs << belief unless user.beliefs.include?(belief)
    belief.user_count += 1
    belief.save
  end
end

# Creates connections between beliefs based on how many users have the same connection in common
Belief.all.each do |belief|
  all_related_beliefs = []
  # For each user it pushes their beliefs into all_related_beliefs array.
  belief.users.each do |user|
    user.beliefs.each do |comparison_belief|
      all_related_beliefs << comparison_belief unless comparison_belief == belief
    end
  end

  all_related_beliefs.each do |related_belief|
    if belief.id < related_belief.id
      first_belief_id = belief.id
      second_belief_id = related_belief.id
    else
      first_belief_id = related_belief.id
      second_belief_id = belief.id
    end
    if @conn = Connection.where(:belief_1_id => first_belief_id, :belief_2_id => second_belief_id).first
      @conn.count += 1
      @conn.save
    else
      Connection.create(belief_1_id: first_belief_id, belief_2_id: second_belief_id)
    end
  end
end

