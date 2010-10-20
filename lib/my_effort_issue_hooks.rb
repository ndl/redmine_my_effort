require 'redmine'

class MyEffortIssueHook < Redmine::Hook::Listener
  
  def controller_issues_edit_before_save(context)
    stop_timer(context)
  end

  def model_changeset_scan_commit_for_issue_ids_pre_issue_update(context)
    stop_timer(context)
  end

  private

  def stop_timer(context)
    begin
      issue = context[:issue]
      old_issue = Issue.find(issue.id)
      time_entry = context[:time_entry]
      # issue.status might be not valid at this point, so we have to
      # use status_id instead.
      closed = IssueStatus.find(issue.status_id).is_closed?
      if old_issue and not old_issue.closed? and closed
        efforts = UserEffort.find(:all, :conditions => {:issue_id => issue.id})
        efforts.each do |effort|
          if not time_entry
            time_entry = TimeEntry.new
            time_entry.user = effort.user
            time_entry.issue = issue
            time_entry.project = issue.project if issue.project_id
            time_entry.activity = Enumeration.find(:first, :conditions => {:type => "TimeEntryActivity", :is_default => 1})
            time_entry.activity = Enumeration.find(:first, :conditions => {:type => "TimeEntryActivity", :name => "Development"}) unless time_entry.activity
            time_entry.activity = Enumeration.find(:first, :conditions => {:type => "TimeEntryActivity"}) unless time_entry.activity
            time_entry.spent_on = Time.now.to_date
            time_entry.hours = effort.hours_spent
            time_entry.save
          else
            if not time_entry.hours
              time_entry.hours = effort.hours_spent
            end
          end
          effort.destroy
        end
      end
    rescue
      Rails.logger.error("Error in stop_timer: #{$!}")
    end
  end
end
