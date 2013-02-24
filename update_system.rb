PublicConfigtasks.create(
	:configtask_id => 0,
	:configname => "Updates OS Packages", 
	:description => "This job updates all installed OS Packages",
   :configtask => <<-'EOF' 

	task "config-update-packages", sub {
		if(is_suse) {
			if(operating_system_version =~ /^11/ ) {
				say run "zypper -n ref -fd";
				say run "zypper -n up -l";
			}
		}
   };

EOF
)
