require 'osx/cocoa'
require 'rubygems'
require 'rubygems/uninstaller'
class GemsController < OSX::NSObject
	include OSX
	ib_outlet :gem_detail_view
	ib_outlet :spinner
	ib_outlet :gem_table
	ib_action :uninstall_gem
	def	initialize
	end
	
	def	uninstall_gem(sender)
		gem = currently_selected_gem
		begin
			Gem::Uninstaller.new(gem[:name], {:version => gem[:version], :all => true, :executables => true}).uninstall
			@gem_detail_view.setStringValue("Uninstalled #{gem[:name]}")
		rescue Gem::FilePermissionError => e
			@gem_detail_view.setStringValue("Cannot uninstall #{gem[:name]}. #{e.message}")
		end
		update_ui
	end
	
	def update_ui
		@gem_details = nil
		@gem_table.reloadData
	end
	
	def	gem_details
		@gem_details ||= fetch_gem_details
	end
	
	def	fetch_gem_details
		@spinner.startAnimation(self)
		gems = Gem.source_index.search /^/i
		result = gems.collect do |spec|
			{:name => spec.name, :version => spec.version.version, :spec => spec}
		end
		@spinner.stopAnimation(self)
		return result
	end
	
	def numberOfRowsInTableView(table_view)
		gem_details.size
	end
	
	def tableView_objectValueForTableColumn_row (tblView, col, row)
		gem = gem_details[row]
		if gem
			return gem[col.identifier.to_s.to_sym]
		end
	end
	
	def currently_selected_gem
		sel = @gem_table.selectedRow
		return gem_details[sel]
	end
	
	def	tableViewSelectionDidChange(notification)
		gem = currently_selected_gem
		@gem_detail_view.setStringValue("Gem: #{gem[:name]}, version: #{gem[:version]}, spec: #{gem[:spec]}")
	end

end
