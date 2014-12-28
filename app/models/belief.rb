class Belief < ActiveRecord::Base
  belongs_to :category
  has_many :user_beliefs, -> { includes(:user) }
  has_many :users, through: :user_beliefs
  has_many :demographics, through: :users

  validates :user_count, numericality: { greater_than_or_equal: 0 }

  include ApplicationHelper

  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.search(query)
    where("definition like ? OR name like ?", "%#{query}%", "%#{query}%")
  end

  def stat_for(category, value)
    self.demographics.where(category => value).count
  end

  def all_stats_for(category)
    results = {}
    return_list_for(category).each do |value|
      results[value] = stat_for(category, value)
    end
    results
  end

  def all_the_stats
    results = {}
    all_categories.each do |category|
      results[category] = all_stats_for(category)
    end
    results
  end

  def list_top_connections
    top_connections = Connection.connected_belief_strengths(self)[0..9]
    passed_connections = []
    top_connections.each do |belief|
      unless belief[1] == 0
        passed_connections << [belief[0].name.capitalize, belief[1]]
      end
    end
    passed_connections
  end

  def strong_convictions
    self.user_beliefs.where('conviction > 50').to_a
  end

  def belief_demographics
    demo_array = []
    self.strong_convictions.each do |ub|
      demo_array << ub.user.demographic unless ub.user.demographic.nil?
    end
    return demo_array
  end

  def group_demographics_by_age
    data_hash = {}
    counter = 1
    99.times do
      data_hash[counter] = 0
      counter += 1
    end
    demographics = self.belief_demographics
    unless demographics.nil?
      demographics.each do |demo|
        unless demo.age.nil?
          data_hash[demo.age] += 1
        end
      end
    end
    # data_array = data_array.group_by {|i| i}.map{ |k,v| [k[0], v.count] }
    return data_hash
  end

  def group_demographics_by_education
    data_array = []
    self.belief_demographics.each do |demo|
      unless demo.education_level.nil?
        data_array << [demo.education_level]
      end
    end
    data_array = data_array.group_by {|i| i}.map{ |k,v| [k, v.count] }
    return data_array
  end

  def group_demographics_by_gender
    data_array = []
    self.belief_demographics.each do |demo|
      unless demo.gender.nil?
        data_array << [demo.gender_sorted]
      end
    end
    data_array = data_array.group_by {|i| i}.map{ |k,v| [k, v.count] }
    return data_array
  end

  def group_demographics_by_religion
    data_array = []
    self.belief_demographics.each do |demo|
      unless demo.religion.nil?
        data_array << [demo.religion_sorted]
      end
    end
    data_array = data_array.group_by {|i| i}.map{ |k,v| [k, v.count] }
    return data_array
  end


  def top_connections_links
    top_connections = Connection.connected_belief_strengths(self)[0..9]
    link_connections = []
    top_connections.each do |belief|
      unless belief[1] == 0
        link_connections << [belief[0].name, belief[1]]
      end
    end
    link_connections
  end

  def rank
    index = Belief.order('user_count DESC').index(self)
    return index + 1
  end

  def self.total_beliefs
    all.count
  end

  def self.all_names
    self.all.map(&:name)
  end
end
