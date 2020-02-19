#Moving .env.dist

Before to start it with deployment you need to create a .env file

You can achieve this, using this command:

~~~
cp .env.dist .env
~~~

After that open the .env file and change the info for that you need.

#Prepare the registry

For GitLab and our Docker Image Registry to communicate with each other, we need a shared certificate. The good thing is, GitLab creates a key for us at bootstrap, only the registry doesn't know about it yet.

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