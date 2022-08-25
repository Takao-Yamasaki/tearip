FROM ruby:3.1.1

# 必要なライブラリをインストール(nodejsはwebpackerをインストールする際に必要)
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# yarnパッケージ管理ツールをインストール(yarnはwebpackerをインストールする際に必要)
RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn


WORKDIR /tearip
COPY Gemfile Gemfile.lock /tearip/
RUN bundle install
COPY . /tearip

# アセットのプリコンパイル
RUN bundle exec rails assets:precompile
# Railsが静的アセットを配信するかどうかの設定
ENV RAILS_SERVE_STATIC_FILES="true"

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
