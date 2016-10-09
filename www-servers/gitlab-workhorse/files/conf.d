RAILS_ENV="production"

app_root=/opt/gitlab
rails_socket=/run/gitlab/gitlab.socket
pid_path="/run/gitlab"
socket_path="/run/gitlab"

gitlab_workhorse_pid_path="$pid_path/gitlab-workhorse.pid"
gitlab_workhorse_options="-listenUmask 0 -listenNetwork unix -listenAddr $socket_path/gitlab-workhorse.socket -authBackend http://127.0.0.1:8080 -authSocket $rails_socket -documentRoot $app_root/public"
gitlab_workhorse_log="/var/log/gitlab/workhorse/gitlab-workhorse.log"
