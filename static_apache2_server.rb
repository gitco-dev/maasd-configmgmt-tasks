PublicConfigtasks.create(
  :configtask_id => 0,
  :configname => "Static Apache2 Server", 
  :description => "This is a simple Apache2 Server",
  :configtask => <<-'EOF'.unindent
 
  # GIT Version: $Id$
 
  task "config-static-apache2", sub {
 
    my $content = "<html><body><h4><a href=\"http://www.rexify.org/\">
                THIS IS A STATIC APACHE2, CONFIGURED VIA REX</a></h4></body></html>";
 
    if(is_debian) {
 
      install package => "apache2-mpm-worker";
 
      file "/var/www/index.html",
        content => $content,
        mode    => 644;
 
      service apache2 => "ensure", "started";
 
    } elsif(is_suse) {
 
      if(operating_system_version =~ /^11/ ) {
 
        install package => "apache2-worker";
 
        file "/srv/www/htdocs/index.html",
          content => $content,
          mode    => 644;
 
        service apache2 => "ensure", "started";
 
      }
 
    } elsif(is_redhat) {
 
      if(operating_system_version =~ /^(5|6)/ ) {
 
        install package => "httpd";
 
        file "/var/www/html/index.html",
          content => $content,
          mode    => 644;
 
        service httpd => "ensure", "started";
 
      }
 
    }
 
  };
  EOF

)

# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
# vim: set ft=ruby:
# vim: set bg=dark:
