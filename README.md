# gitea-environment

When running, the following applications will be available on your localhost:

* **Gitea:** http://gitea:3000
* **Drone:** http://drone:8002
* **Minio:** http://minio:9000

## Getting Started

Run:

``` bash
./service.sh start
```

Then, load the following in your browser:

* http://gitea:3000 - Configure and register for a Gitea account; database
  configuration may be left as-is
* http://drone:8002 - Log in to Drone using the same credentials you used
  for your Gitea account

Create an SSH key to use with Gitea by running `ssh-keygen` from your terminal.
When prompted for the name of the key file, use something like
`/Users/username/.ssh/gitea-local`.

Then, add the following to your local host's `~/.ssh/config` file:

```
Host gitea
HostName gitea
Port 222
User git
IdentityFile ~/.ssh/gitea-local
```

Finally, type `cat ~/.ssh/gitea-local.pub` from your terminal and copy-and-paste
the output into a new SSH key in your Gitea account:
http://gitea:3000/user/settings/keys

## Trying It Out

Let's create a PHP project that we'll add to Gitea and then run tests for in
Drone.

``` bash
composer create-project ramsey/php-library-skeleton drone-test
```

Answer all the questions. When completed, `cd drone-test/` and create a
`.drone.yml` file with the following:

``` yaml
kind: pipeline
name: default

steps:
  - name: unit
    image: php:7.3-alpine
    commands:
      - curl -L -s -o composer.phar https://getcomposer.org/download/1.8.5/composer.phar
      - php --version
      - php composer.phar --version
      - php composer.phar install --no-interaction --prefer-dist --no-progress
      - php composer.phar run test-ci
```

Now, go to Gitea and create your repository: http://gitea:3000/repo/create.
Name it "drone-test" in keeping with the examples here.

Log into Drone and click the "SYNC" button to load your repositories from Gitea.
Click to activate your "drone-test" repository. Now, you're ready to push your
repository to Gitea and watch the build run.

From your `drone-test/` directory in your terminal, type the following:

``` bash
git init
git add .
git commit -m "Initial commit"
git remote add origin git@gitea:ramsey/drone-test.git
git push -u origin master
```

If you've still got your Drone window visible, you should see it start to kick
off a build.

Yay! 🎉
