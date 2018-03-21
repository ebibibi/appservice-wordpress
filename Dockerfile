FROM wordpress

RUN a2enmod rewrite

# ------------------------
# SSH Server support(not enabled yet)
# ------------------------
RUN apt-get update \ 
  && apt-get install -y --no-install-recommends openssh-server \
  && echo "root:Docker!" | chpasswd

COPY sshd_config /etc/ssh/
EXPOSE 2222

COPY init_container.sh /bin/
RUN chmod 755 /bin/init_container.sh 
#CMD ["sh", "/bin/init_container.sh"]

#--------------------------
# Install wordpress plugins
#--------------------------
# これから使う`wget`と`unzip`を入れる
RUN apt-get update
RUN apt-get -y --force-yes -o Dpkg::Options::="--force-confdef" install wget unzip

# プラグインファイルの一時ダウンロード先
WORKDIR /tmp/wp-plugins

# プラグインファイルをダウンロード
RUN wget https://downloads.wordpress.org/plugin/akismet.4.0.3.zip
RUN wget https://downloads.wordpress.org/plugin/bbpress.2.5.14.zip
RUN wget https://downloads.wordpress.org/plugin/ewww-image-optimizer.4.1.1.zip
RUN wget https://downloads.wordpress.org/plugin/google-sitemap-generator.4.0.9.zip
RUN wget https://downloads.wordpress.org/plugin/jetpack.5.9.zip
RUN wget https://downloads.wordpress.org/plugin/regenerate-thumbnails.zip
RUN wget https://downloads.wordpress.org/plugin/simple-feature-requests.zip
RUN wget https://downloads.wordpress.org/plugin/pubsubhubbub.2.2.1.zip
RUN wget https://downloads.wordpress.org/plugin/wordfence.7.1.1.zip
RUN wget https://downloads.wordpress.org/plugin/wp-fastest-cache.0.8.7.8.zip
RUN wget https://downloads.wordpress.org/plugin/wp-multibyte-patch.2.8.1.zip
RUN wget https://downloads.wordpress.org/plugin/wp-azure-offload.1.0.zip




# プラグインをWordPressのプラグインディレクトリに解凍する
RUN unzip -o './*.zip' -d /usr/src/wordpress/wp-content/plugins
RUN chown -R www-data:www-data /usr/src/wordpress/wp-content

# 一時ダウンロード先内の全ファイルの削除
RUN rm -rf '/tmp/wp-plugins'

# 戻る
WORKDIR /var/www/html

#------------------------
# Install Wordpress theme
#------------------------

# テーマファイルの一時ダウンロード先
WORKDIR /tmp/wp-themes

# テーマファイルをダウンロード
RUN wget https://github.com/ebibibi/appservice-wordpress/raw/master/Themes/cocoon-child-master.zip
RUN wget https://github.com/ebibibi/appservice-wordpress/raw/master/Themes/cocoon-master-0.2.4.zip


# テーマをWordPressのテーマディレクトリに解凍する
RUN unzip './*.zip' -d /usr/src/wordpress/wp-content/themes
RUN chown -R www-data:www-data /usr/src/wordpress/wp-content

# 一時ダウンロード先内の全ファイルの削除
RUN rm -rf '/tmp/wp-themes'

# 戻る
WORKDIR /var/www/html


#------------------------
# 実行
#------------------------
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh 
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]