#!/bin/bash

set -x

export ADMIN_PASSWORD=$1
password=$1


function wait_for_jenkins()
{
  while (( 1 )); do
      echo "waiting for Jenkins to launch on port [8080] ..."
      
      nc -zv 127.0.0.1 8080
      if (( $? == 0 )); then
          break
      fi

      sleep 10
  done

  echo "Jenkins launched"
}

function updating_jenkins_master_password ()
{
  cat > /tmp/jenkinsHash.py <<EOF
import bcrypt
import os
import sys


plaintext_pwd = os.environ.get("ADMIN_PASSWORD", )
encrypted_pwd = bcrypt.hashpw(plaintext_pwd.encode('utf-8'), bcrypt.gensalt(rounds=10, prefix=b"2a"))
isCorrect = bcrypt.checkpw(plaintext_pwd.encode('utf-8'), encrypted_pwd)

if not isCorrect:
  sys.exit(20);

print(encrypted_pwd.decode("utf-8"))

EOF

  chmod +x /tmp/jenkinsHash.py
  
  # Wait till /var/lib/jenkins/users/admin* folder gets created
  sleep 10

  sudo chmod a+rwx /var/lib/jenkins/users/admin*
  cd /var/lib/jenkins/users/admin*
  pwd
  while (( 1 )); do
      echo "Waiting for Jenkins to generate admin user's config file ..."

      if [[ -f "./config.xml" ]]; then
          break
      fi

      sleep 10
  done

  echo "Admin config file created"

  pip3 install bcrypt

  admin_password=$(python3 /tmp/jenkinsHash.py)

  echo $admin_password
  
  # Please do not remove alter quote as it keeps the hash syntax intact or else while substitution, $<character> will be replaced by null
  xmlstarlet -q ed --inplace -u "/user/properties/hudson.security.HudsonPrivateSecurityRealm_-Details/passwordHash" -v '#jbcrypt:'$admin_password config.xml

  # Restart
  systemctl restart jenkins
  sleep 10
}

function install_packages ()
{

  sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  sudo yum upgrade
  sudo yum install -y jenkins

  # firewall
  #firewall-cmd --permanent --new-service=jenkins
  #firewall-cmd --permanent --service=jenkins --set-short="Jenkins Service Ports"
  #firewall-cmd --permanent --service=jenkins --set-description="Jenkins Service firewalld port exceptions"
  #firewall-cmd --permanent --service=jenkins --add-port=8080/tcp
  #firewall-cmd --permanent --add-service=jenkins
  #firewall-cmd --zone=public --add-service=http --permanent
  #firewall-cmd --reload
  systemctl enable jenkins
  systemctl restart jenkins
  sleep 10
}

function configure_jenkins_server ()
{
  # Jenkins cli
  echo "installing the Jenkins cli ..."

  sudo curl --output jenkins-cli.jar 127.0.0.1:8080/jnlpJars/jenkins-cli.jar

  cp jenkins-cli.jar /var/lib/jenkins/jenkins-cli.jar

  # Getting initial password
  # PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
  PASSWORD=$password
  sleep 10

  jenkins_dir="/var/lib/jenkins"
  plugins_dir="$jenkins_dir/plugins"

  cd $jenkins_dir

  # Open JNLP port
  xmlstarlet -q ed --inplace -u "/hudson/slaveAgentPort" -v 33453 config.xml

  cd $plugins_dir || { echo "unable to chdir to [$plugins_dir]"; exit 1; }

  # List of plugins that are needed to be installed 
  plugin_list="git-client git github-api github-oauth github MSBuild ssh-slaves workflow-aggregator ws-cleanup"

  # remove existing plugins, if any ...
  rm -rfv $plugin_list

  for plugin in $plugin_list; do
      echo "installing plugin [$plugin] ..."
      java -jar $jenkins_dir/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth admin:$PASSWORD install-plugin $plugin
  done

  # Restart jenkins after installing plugins
  java -jar $jenkins_dir/jenkins-cli.jar -s http://127.0.0.1:8080 -auth admin:$PASSWORD safe-restart
}

### script starts here ###

install_packages

wait_for_jenkins

updating_jenkins_master_password

wait_for_jenkins

configure_jenkins_server

echo "Done"
exit 0