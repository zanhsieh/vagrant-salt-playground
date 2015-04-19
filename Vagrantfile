# -*- mode: ruby -*-
# vi: set ft=ruby :

$IPs = {
  "master1"     => "10.0.135.100",
  "min01"       => "10.0.135.10",
  "min02"       => "10.0.135.20",
}

$ports = [4505,4506,389]

def gen_roster(ips={}, exclude=[])
  return ips.map {|k,v|
  if not exclude.include? (k)
<<-INNER
#{k}:
  host: #{v}
  user: vagrant
  passwd: vagrant
  sudo: True
INNER
  end
  }.join
end

def host_check(ips={})
  return ips.map {|k,v|<<-INNER
if [ ! `grep -q #{v} /etc/hosts` ]; then
  echo '#{v} #{k}' | sudo tee -a /etc/hosts
fi
  INNER
  }.join
end

def firewall_setup(ports=[])
  case ports.size
  when 0
    return
  else
    return <<-INNER
if [ ! `grep -q '#{ports.join('\|')}' /etc/sysconfig/iptables` ]; then
  echo "Open port #{ports.join(',')}"
  LN=$(iptables -L --line-numbers | grep REJECT | cut -d ' ' -f1 | head -n 1)
  iptables -N allow_services
  iptables -I INPUT $LN -j allow_services
  iptables -A allow_services -p tcp --match multiport --dports #{ports.join(',')} -j ACCEPT
  service iptables save
  service iptables restart
fi
    INNER
  end
end

def locale_setup
  return <<-LOCALESETUP
rm -f /etc/sysconfig/clock
echo "ZONE=\"Asia/Hong_Kong\"" > /etc/sysconfig/clock
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
[ -z "$LC_ALL" ] && echo "export LC_ALL=$LANG" >> /etc/profile.d/lang.sh
  LOCALESETUP
end

def master_setup(m)
  return <<-MASTERSETUP
#{firewall_setup($ports)}
if [ ! -f "/var/salt_master_setup" ]; then
echo "Install salt-master"
yum -y install epel-release
yum -y --enablerepo=epel install salt-master salt-ssh
chkconfig salt-master on
[ ! -d /etc/salt/master.d ] && mkdir -p /etc/salt/master.d
echo 'interface: #{$IPs[m]}' > /etc/salt/master.d/master.conf
cp /vagrant/salt/master.d/file.conf /etc/salt/master.d/
cp /vagrant/salt/master.d/pillar.conf /etc/salt/master.d/
cp /vagrant/salt/master.d/reactor.conf /etc/salt/master.d/
tee /etc/salt/roster <<-EOF
#{gen_roster($IPs, ["master1"])}
EOF
ln -s /vagrant/srv/pillar /srv/pillar
ln -s /vagrant/srv/salt /srv/salt
ln -s /vagrant/srv/reactor /srv/reactor
service salt-master start
touch /var/salt_master_setup
fi
  MASTERSETUP
end

def salt_minion_setup(m)
  return <<-SALTMINIONSETUP
if [ ! -f "/var/salt_minion_setup" ]; then
echo "Install salt-minion"
yum -y install epel-release
yum -y --enablerepo=epel install salt-minion
chkconfig salt-minion on
[ ! -d /etc/salt/minion.d ] && mkdir -p /etc/salt/minion.d
tee /etc/salt/minion.d/master.conf <<-EOF
master: master1
EOF
service salt-minion start
touch /var/salt_minion_setup
fi
  SALTMINIONSETUP
end


Vagrant.configure(2) do |config|
  config.vm.box = "centos66"
  config.vm.box_check_update = false
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = "box"
    config.cache.synced_folder_opts = {
      type: "nfs",
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
  end
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end
  #config.vm.synced_folder '.', '/vagrant', nfs: true

  $IPs.map do |k,v|
    config.vm.define "#{k}" do |m|
      m.vm.hostname = "#{k}"
      m.vm.network "private_network", ip: "#{v}"
      if k == 'master1'
        m.vm.network "forwarded_port", guest: 389, host: 3389
      end
      m.vm.provider "virtualbox" do |v|
        v.memory = 512
      end
      m.vm.provision "shell", inline:<<-SHELL
      #{host_check($IPs)}
      SHELL
      m.vm.provision "shell", inline:<<-SHELL
      #{locale_setup}
      SHELL
      m.vm.provision "shell", inline:<<-SHELL
      #{case k
        when "master1"
          master_setup(k)
        else
          salt_minion_setup(k)
        end
      }      
      SHELL
    end
  end
end
