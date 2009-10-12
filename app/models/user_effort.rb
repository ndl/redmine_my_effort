class UserEffort < ActiveRecord::Base
  belongs_to :user
  has_one :issue

  validates_presence_of :issue_id

  def initialize(arguments = nil)
    #Start timer
    super(arguments)
    self.start_time = DateTime.now
    self.active = true
    self.user_id = User.current.id
  end

  def hours_spent
    hours, minutes = Date.day_fraction_to_time(DateTime.now - start_time.to_datetime)
    minutes += hours * 60
    rtick = (Setting.plugin_redmine_my_effort['tick_interval']).to_i
    rtick * (minutes.to_f / rtick.to_f).round / 60.0
  end

end
