require 'redmine'

Redmine::Plugin.register :redmine_my_effort do
  name :plugin_name
  author 'Oleg Vivtash'
  description :plugin_description
  version '0.1.0'

  permission :my_effort, {:user_efforts => [:index, :new, :stop]}, :require => :member
  menu :top_menu, :my_effort, { :controller => 'user_efforts', :action => 'index' }, :caption => :my_effort_title

  settings :default => {
    'tick_interval' => '30'
  }, :partial => 'settings/myeffort_settings'

end

