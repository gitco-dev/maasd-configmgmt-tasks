public_tasks = PublicConfigtasks.create(
  :configtask_id => 0,
  :configname => "HSFlow Daemon", 
  :configvars => {
    "gmond_sflow_ip"   => "127.0.0.1",
    "gmond_sflow_port" => "6343"
  },
  :description => "HSFlow Daemon http:/www.sflow.com",
  :configtask => <<-EOF.unindent

  # GIT Version: $Id$
  
  task "config-hsflowd-agent", sub {

    if(is_suse) {
      if(operating_system_version =~ /^11/ ) {

        install package => "hsflowd";

        file "/etc/hsflowd.conf",
          content => template("\@hsflowd.conf",
            gmond_sflow_ip     => "#|gmond_sflow_ip|#",
            gmond_sflow_port   => "#|gmond_sflow_port|#",
        ), 
        mode    => 644;

        service hsflowd => "ensure", "started";
      }
    }
  };  


  __DATA__

  @hsflowd.conf
  sflow{
    DNSSD = off
    polling = 30
    sampling = 4000
    collector{
      ip = <%= $::gmond_sflow_ip %>
      udpport = <%= $::gmond_sflow_port %>
    }
  }
  @end

  EOF
)

# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
# vim: set ft=ruby:
# vim: set bg=dark:
