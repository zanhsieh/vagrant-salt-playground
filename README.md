# vagrant-salt-playground

1. separate os/apps branch, each branch have base/tb/prod ("salt '*' state.highstate saltenv=os_tb", check master.d/files.conf & master.d/pillar.conf) 
2. demo composite with jinja include or salt top file (check top.sls in os/prod/top.sls and os/tb/top.sls)
3. extend salt reactor on [official document]("http://docs.saltstack.com/en/latest/topics/reactor/#a-complete-example") to work on tb/prod environment (check reactor/*.sls and master.d/reactor.conf)
