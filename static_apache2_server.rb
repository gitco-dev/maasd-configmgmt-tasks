PublicConfigtasks.create(
	:configtask_id => 0,
	:configname => "Static Apache2 Server", 
   :configtask => 'task "config-static-apache2", sub {

  if(is_debian) {

    install package => "apache2-mpm-worker";

    file "/var/www/index.html",
          content => "<html><body><h4><a href=\"http://www.rexify.org/\">
                    THIS IS A STATIC APACHE2, CONFIGURED VIA REX</a></h4></body></html>",
        mode    => 644;

    service apache2 => "ensure", "started";
  } elsif(is_suse) {
    if(operating_system_version =~ /^11/ ) {
      install package => "apache2-worker";

      file "/srv/www/htdocs/index.html",
          content => "<html><body><h4><a href=\"http://www.rexify.org/\">
                    THIS IS A STATIC APACHE2, CONFIGURED VIA REX</a></h4></body></html>",
        mode    => 644;

      service apache2 => "ensure", "started";

    }
  }
};',
	:description => "This is a simple Apache2 Server"
)
