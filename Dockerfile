FROM ruby:2.5.1

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - &&\
    apt-get update -qq &&\
    apt-get install -y build-essential nodejs postgresql-client graphviz task-japanese fonts-ipafont fonts-noto-cjk
ENV TZ=Asia/Tokyo

WORKDIR /usr/src/app
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

COPY . .

EXPOSE 3000
CMD /bin/sh -c "rm /usr/src/app/tmp/pids/server.pid; bundle exec puma -C config/puma.rb"
# CMD /bin/sh -c "rm /usr/src/app/tmp/pids/server.pid; bin/rails s"