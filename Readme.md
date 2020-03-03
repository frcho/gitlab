# Moving .env.dist

Before to start it with deployment you need to create a .env file

You can achieve this, using this command:

~~~
cp .env.dist .env
~~~

After that open the .env file and change the info for that you need.

# Prepare the registry

Edit the daemon.json file, whose default location is /etc/docker/daemon.json on Linux

If the daemon.json file does not exist, create it. Assuming there are no other settings in the file, it should have the following contents:

~~~
{
  "insecure-registries" : ["registry.gitlab.localhost:5000"]
}
~~~

Restart Docker for the changes to take effect.

~~~
sudo systemctl restart docker
~~~

We need to register the url to /etc/hosts, you need run a commnad like sudo user:

~~~
sudo su
~~~

To directly modify the file (and create a backup) – works with BSD and GNU sed:

~~~
sed -i.bak '/registry.gitlab.localhost/d' /etc/hosts &&  echo "$(docker inspect -f '{{ .NetworkSettings.Networks.gitlab_gitlab.IPAddress}}' gitlab_registry)    registry.gitlab.localhost" >> /etc/hosts
~~~

Now we can test if everything was well

~~~
docker login registry.gitlab.localhost:5000
~~~

The above command request user and password, please type it, if everything gone well.


If you can see something like this, Great it, otherwise try again.

WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

And now for GitLab and our Docker Image Registry to communicate with each other, we need a shared certificate.
The good thing is, GitLab creates a key for us at bootstrap, only the registry doesn't know about it yet.
What we have to do is copy the certificate key created by GitLab into the volume of the registry and create a certificate out of it. Let's do it:

~~~
docker cp gitlab:/var/opt/gitlab/gitlab-rails/etc/gitlab-registry.key .
openssl req  -key gitlab-registry.key -new -subj "/CN=gitlab-issuer" -x509 -days 365 -out gitlab-registry.crt
mv  gitlab-registry.crt .data/gitlab/registry/certs
~~~


# Validate if the email are sending

**Using gitlab-rails console**

~~~

gitlab-rails console

Notify.test_email('webmaster@kijho.com', 'gitlab test', 'Test message').deliver_now
~~~

# Create runner

For achieve this, you need to access gitlab-runner container, use next command:

~~~
docker-compose exec gitlab-runner bash
~~~

Now you need get the token, go to http://gitlab.localhost/admin/runners

~~~bash
 TOKEN=<YOUR_TOKEN>
~~~

And then run this command for create the runner.

~~~bash
 gitlab-runner register -n   --url http://gitlab.localhost/  --registration-token ${TOKEN}   --executor docker   --description "DockerInDocker"   --docker-image "docker:stable"   --tag-list "docker"   --locked=false   --run-untagged=false  --docker-network-mode "host" --docker-privileged=false   --docker-volumes /var/run/docker.sock:/var/run/docker.sock
~~~


 gitlab-runner register -n   --url https://ci.uva3.com/  --registration-token WVgHh3Sfyb6kyHG5gmix   --executor docker   --description "websites-docker-executor-ci"   --docker-image "docker:stable"   --tag-list "websites-docker"   --locked=false   --run-untagged=false  --docker-network-mode "host" --docker-privileged=false   --docker-volumes /var/run/docker.sock:/var/run/docker.sock