FROM alpine:latest as base
MAINTAINER haokexin1214@gmail.com
ENV TZ=Asia/Tokyo
ARG GITUSER=haokexin
ARG GITEMAIL=haokexin1214@gmail.com
ADD .bashrc ~/.bashrc
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apk --no-cache add -y build-essential python3-dev mono-complete golang nodejs default-jdk npm wget git ctags\
    && apk --no-cache add libtinfo-dev locales cmake make gcc g++ -y \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 \
    && apk cache clean -y \
    && git config --global user.email $GITEMAIL \
    && git config --global user.name $GITUSER \
    && cd / \
	&& git clone https://github.com/vim/vim.git \
    && cd vim \
    && ./configure --with-features=huge \
	               --enable-python3interp=yes \
	               --with-python3-config-dir=/usr/lib/python3.8/config-3.8-x86_64-linux-gnu/ \
	               --enable-cscope --prefix=/usr \
   	               --enable-multibyte \
    && make VIMRUNTIMEDIR=/usr/share/vim/vim82 \
    && make install \
    && rm -rf /vim
ADD gruvbox.vim /usr/share/vim/vim82/colors/gruvbox.vim
ADD .vimrc ~/.vimrc
ADD vim/ ~/.vim/
RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim \
    && vim +PluginInstall +qall \
    && cd ~/.vim/bundle/YouCompleteMe \
    && git submodule sync --recursive \
    && git submodule update --init --recursive \
    && python3 ~/.vim/bundle/YouCompleteMe/install.py --all \
    && apk del libtinfo-dev build-essential cmake wget make gcc g++ -y \
    && find ~/.vim/ -name ".git*" | xargs rm -Rf \
    && rm -rf ~/.vim/bundle/YouCompleteMe/third_party/ycmd/clang_archives
ADD --chown=root:root fzf-0.24.4-linux_amd64.tar.gz ~/.vim/bundle/fzf/bin/
CMD ["/bin/bash"]
