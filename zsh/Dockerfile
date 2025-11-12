# Start with Arch base
FROM archlinux:latest

# Create user with matching UID/GID from build args
ARG UID=1000
ARG GID=1000
ARG USERNAME="theron"

# Install comprehensive set of tools
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        base-devel \
        git \
        zsh \
        curl \
        wget \
        neovim \
        vim \
        fzf \
        ripgrep \
        eza \
        tmux \
        python \
        python-pip \
        nodejs \
        npm \
        cargo \
        go \
        openssh \
        sudo \
        which \
        tree \
        jq \
        yq \
        sqlite \
        unzip \
        tar \
        gzip \
        xz \
        man-db \
        man-pages \
        less \
        ncurses \
        diffutils \
        patch \
        sed \
        awk \
        grep \
        findutils \
        coreutils \
        util-linux \
        procps-ng \
        psmisc \
        htop \
        btop \
        net-tools \
        iproute2 \
        bind-tools \
        traceroute \
        iputils && \
    pacman -Scc --noconfirm
    
RUN paru  -Syu --noconfirm && \
    pacman -S --noconfirm \
    yazi-nightly-bin &&
  paru -Scc --noconfirm

RUN groupadd -g ${GID} ${USERNAME} 2>/dev/null || true && \
    useradd -m -u ${UID} -g ${GID} -s /bin/zsh ${USERNAME} 2>/dev/null || true

# # Create user after packages are installed
# RUN useradd -m -s /usr/bin/zsh theron
#
# USER theron

# Install Claude CLI
RUN curl -fsSL https://github.com/anthropics/claude-code/releases/latest/download/install.sh | bash || \
    echo "Claude CLI installation skipped (optional)"

# Switch to user
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Create directory structure matching host exactly
RUN mkdir -p \
    /home/${USERNAME}/.core/cfg/zsh \
    /home/${USERNAME}/.core/cfg/tmux \
    /home/${USERNAME}/.core/cfg/yazi \
    /home/${USERNAME}/.core/cfg/nvim \
    /home/${USERNAME}/.core/bin \
    /home/${USERNAME}/.core/tbin \
    /home/${USERNAME}/.core/env \
    /home/${USERNAME}/.core/dev \
    /home/${USERNAME}/.core/ref/zsh \
    /home/${USERNAME}/.cache \
    /home/${USERNAME}/.local/share \
    /home/${USERNAME}/.config \
    /home/${USERNAME}/.zinit \
    /home/${USERNAME}/exports

# Copy safe config only (not full config, that's mounted)
COPY --chown=${USERNAME}:${USERNAME} safe-config /home/${USERNAME}/.core/cfg/zsh/safe-config

# Set environment variables
ENV ZDOTDIR=/home/${USERNAME}/.core/cfg/zsh/safe-config
ENV HOME=/home/${USERNAME}
ENV SHELL=/usr/bin/zsh
ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV DOCKER_BUILD=1
ENV ZSH_SAFE_MODE=1

# Pre-install zinit for main config
RUN git clone https://github.com/zdharma-continuum/zinit.git /home/${USERNAME}/.zinit/bin

# Create symlink for safe config .zshenv
RUN ln -sf /home/${USERNAME}/.core/cfg/zsh/safe-config/.zshenv /home/${USERNAME}/.zshenv

# Test that safe config works
RUN zsh -c 'source $HOME/.zshenv && echo "Safe config OK"'

# Set up a marker file to indicate docker environment
RUN touch /home/${USERNAME}/.dockerenv

# Copy and set up entrypoint script
COPY --chown=${USERNAME}:${USERNAME} docker-entrypoint.sh /home/${USERNAME}/docker-entrypoint.sh
RUN chmod +x /home/${USERNAME}/docker-entrypoint.sh

# Set working directory
WORKDIR /home/${USERNAME}/.core/cfg/zsh

# Use entrypoint script
ENTRYPOINT ["/home/${USERNAME}/docker-entrypoint.sh"]
CMD ["/usr/bin/zsh", "-i", "-l"]
