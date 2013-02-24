PublicConfigtasks.create(
	:configtask_id => 0,
	:configname => "Minimal Ganglia Server", 
	:description => "This is a minimal Ganglia Install Task",
   :configtask => <<-'EOF' 

	task "config-ganglia-server", sub {

	if(is_suse) {
		if(operating_system_version =~ /^11/ ) {

			install package => [ "libganglia",
										"ganglia-web",
										"ganglia-gmond",
										"ganglia-gmetad",
										"apache2-prefork",
										"apache2-mod_php5",
										"php5", 
										"php5-iconv", 
										"php5-suhosin", 
										"php5-xmlreader", 
										"php5-pdo", 
										"php5-dom", 
										"php5-xmlwriter", 
										"php5-json", 
										"php5-ctype", 
										"php5-gd", 
										"php5-tokenizer", 
										"php5-sqlite", 
										"php5-hash"
										];

			file "/etc/ganglia/gmetad.conf",
			content => template("\@suse_gmetad.conf"), 
			mode    => 644;

			file "/etc/ganglia/gmond.conf",
			content => template("\@suse_gmond.conf"), 
			mode    => 644;

			file "/srv/www/htdocs/index.html",
			content => template("\@suse_index.html"),
			mode    => 644;

			chown "wwwrun", "/var/lib/ganglia/dwoo",
			recursive => 1;
			chgrp "www", "/var/lib/ganglia/dwoo",
			recursive => 1;

			sed qr{\$conf\['heatmaps_enabled'\] = 1}, "\$conf['heatmaps_enabled'] = 0", "/srv/www/htdocs/gweb/conf_default.php";

			service apache2 => "ensure", "started";
			service gmond   => "ensure", "started";
			service gmetad  => "ensure", "started";
		}
	}
};  


__DATA__

@suse_gmetad.conf
data_source "my cluster" localhost
case_sensitive_hostnames 1
@end

@suse_gmond.conf
globals {
	daemonize = yes
	setuid = yes
	user = nobody
	debug_level = 0
	max_udp_msg_len = 1472
	mute = no
	deaf = no
	allow_extra_data = yes
	host_dmax = 259200 /*secs delete a host if we haven't seen it for 3 days*/
	host_tmax = 20 /*secs */
	cleanup_threshold = 300 /*secs */
	gexec = no
	send_metadata_interval = 300 /*secs */
	/* override_hostname = myhost.example.com */
}

/*
* The cluster attributes specified will be used as part of the <CLUSTER>
* tag that will wrap all hosts collected by this instance.
*/
cluster {
	name = "DEFAULT-CLUSTER"
	owner = "unspecified"
	latlong = "unspecified"
	url = "unspecified"
}

/* The host section describes attributes of the host, like the location */
host {
	location = "unspecified"
}

/* Feel free to specify as many udp_send_channels as you like. */
udp_send_channel {
	bind_hostname = no   # "yes" Highly recommended, soon to be default.
	# This option tells gmond to use a source address
	# that resolves to the machine's hostname.  Without
	# this, the metrics may appear to come from any
	# interface and the DNS names associated with
	# those IPs will be used to create the RRDs.
	host = "127.0.0.1" /* For your monitor node use 127.0.0.1, for your monitored nodes use the address or hostname of your monitor node */
	port = 8649
	ttl = 10
}

/* You can specify as many udp_recv_channels as you like as well. */
udp_recv_channel {
	port = 8649
}

/* You can specify as many tcp_accept_channels as you like to share
an xml description of the state of the cluster */
tcp_accept_channel {
port = 8649
}

/* Channel to receive sFlow datagrams */
udp_recv_channel {
	port = 6343
}

/* Optional sFlow settings */
sflow {
	udp_port = 6343
	accept_vm_metrics = yes
}

/* Each metrics module that is referenced by gmond must be specified and
loaded. If the module has been statically linked with gmond, it does
not require a load path. However all dynamically loadable modules must
include a load path. */
modules {
		module {
			name = "core_metrics"
		}
	module {
		name = "cpu_module"
		path = "modcpu.so"
	}
	module {
		name = "disk_module"
		path = "moddisk.so"
	}
	module {
		name = "load_module"
		path = "modload.so"
	}
	module {
		name = "mem_module"
		path = "modmem.so"
	}
	module {
		name = "net_module"
		path = "modnet.so"
	}
	module {
		name = "proc_module"
		path = "modproc.so"
	}
	module {
		name = "sys_module"
		path = "modsys.so"
	}
}

/* This collection group will cause a heartbeat (or beacon) to be sent every
20 seconds.  In the heartbeat is the GMOND_STARTED data which expresses
the age of the running gmond. */
collection_group {
	collect_once = yes
	time_threshold = 20
	metric {
		name = "heartbeat"
	}
}

/* This collection group will send general info about this host every
1200 secs.
This information doesn't change between reboots and is only collected
once. */
collection_group {
	collect_once = yes
	time_threshold = 1200
	metric {
		name = "cpu_num"
		title = "CPU Count"
	}
	metric {
		name = "cpu_speed"
		title = "CPU Speed"
	}
	metric {
		name = "mem_total"
		title = "Memory Total"
	}
	/* Should this be here? Swap can be added/removed between reboots. */
	metric {
		name = "swap_total"
		title = "Swap Space Total"
	}
	metric {
		name = "boottime"
		title = "Last Boot Time"
	}
	metric {
		name = "machine_type"
		title = "Machine Type"
	}
	metric {
		name = "os_name"
		title = "Operating System"
	}
	metric {
		name = "os_release"
		title = "Operating System Release"
	}
	metric {
		name = "location"
		title = "Location"
	}
}

/* This collection group will send the status of gexecd for this host
every 300 secs.*/
collection_group {
	collect_once = yes
	time_threshold = 300
	metric {
		name = "gexec"
		title = "Gexec Status"
	}
}

/* This collection group will collect the CPU status info every 20 secs.
The time threshold is set to 90 seconds.  In honesty, this
time_threshold could be set significantly higher to reduce
unneccessary  network chatter. */
collection_group {
	collect_every = 20
	time_threshold = 90
	/* CPU status */
	metric {
		name = "cpu_user"
		value_threshold = "1.0"
		title = "CPU User"
	}
	metric {
		name = "cpu_system"
		value_threshold = "1.0"
		title = "CPU System"
	}
	metric {
		name = "cpu_idle"
		value_threshold = "5.0"
		title = "CPU Idle"
	}
	metric {
		name = "cpu_nice"
		value_threshold = "1.0"
		title = "CPU Nice"
	}
	metric {
		name = "cpu_aidle"
		value_threshold = "5.0"
		title = "CPU aidle"
	}
	metric {
		name = "cpu_wio"
		value_threshold = "1.0"
		title = "CPU wio"
	}
	/* The next two metrics are optional if you want more detail...
	... since they are accounted for in cpu_system.
	metric {
		name = "cpu_intr"
		value_threshold = "1.0"
		title = "CPU intr"
	}
	metric {
		name = "cpu_sintr"
		value_threshold = "1.0"
		title = "CPU sintr"
	}
	*/
}

collection_group {
	collect_every = 20
	time_threshold = 90
	/* Load Averages */
	metric {
		name = "load_one"
		value_threshold = "1.0"
		title = "One Minute Load Average"
	}
	metric {
		name = "load_five"
		value_threshold = "1.0"
		title = "Five Minute Load Average"
	}
	metric {
		name = "load_fifteen"
		value_threshold = "1.0"
		title = "Fifteen Minute Load Average"
	}
}

/* This group collects the number of running and total processes */
collection_group {
	collect_every = 80
	time_threshold = 950
	metric {
		name = "proc_run"
		value_threshold = "1.0"
		title = "Total Running Processes"
	}
	metric {
		name = "proc_total"
		value_threshold = "1.0"
		title = "Total Processes"
	}
}

/* This collection group grabs the volatile memory metrics every 40 secs and
sends them at least every 180 secs.  This time_threshold can be increased
significantly to reduce unneeded network traffic. */
collection_group {
	collect_every = 40
	time_threshold = 180
	metric {
		name = "mem_free"
		value_threshold = "1024.0"
		title = "Free Memory"
	}
	metric {
		name = "mem_shared"
		value_threshold = "1024.0"
		title = "Shared Memory"
	}
	metric {
		name = "mem_buffers"
		value_threshold = "1024.0"
		title = "Memory Buffers"
	}
	metric {
		name = "mem_cached"
		value_threshold = "1024.0"
		title = "Cached Memory"
	}
	metric {
		name = "swap_free"
		value_threshold = "1024.0"
		title = "Free Swap Space"
	}
}

collection_group {
	collect_every = 40
	time_threshold = 300
	metric {
		name = "bytes_out"
		value_threshold = 4096
		title = "Bytes Sent"
	}
	metric {
		name = "bytes_in"
		value_threshold = 4096
		title = "Bytes Received"
	}
	metric {
		name = "pkts_in"
		value_threshold = 256
		title = "Packets Received"
	}
	metric {
		name = "pkts_out"
		value_threshold = 256
		title = "Packets Sent"
	}
}

collection_group {
	collect_every = 1800
	time_threshold = 3600
	metric {
		name = "disk_total"
		value_threshold = 1.0
		title = "Total Disk Space"
	}
}

collection_group {
	collect_every = 40
	time_threshold = 180
	metric {
		name = "disk_free"
		value_threshold = 1.0
		title = "Disk Space Available"
	}
	metric {
		name = "part_max_used"
		value_threshold = 1.0
		title = "Maximum Disk Space Used"
	}
}

include ("/etc/ganglia/conf.d/*.conf")
@end

@suse_index.html
<html>
<head>
<meta http-equiv="refresh" content="0;URL=gweb/">
<title>GANGLIA - MONITORING</title>
</head>
</html>
@end

EOF
)