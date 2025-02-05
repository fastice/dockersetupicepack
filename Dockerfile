# Get base image
FROM firedrakeproject/firedrake-vanilla:2025-01
# update
RUN sudo apt update
RUN sudo apt-get -y install  software-properties-common
RUN sudo add-apt-repository ppa:ubuntugis/ppa
RUN sudo apt  -y install patchelf
RUN sudo apt -y install gdal-bin libgdal-dev
# install icepack stuff
RUN source /home/firedrake/firedrake/bin/activate && \
    pip install git+https://github.com/icepack/Trilinos.git && \
    pip install git+https://github.com/icepack/pyrol.git && \
    git clone https://github.com/icepack/icepack.git && \
    pip install --editable ./icepack && \
    pip install jupyter lab && \
    pip install siphash24
#
# DockerRequirements.txt contains all extra packages and is copied to containter
COPY  DockerRequirements.txt .
# Set up the kernel and other packages
RUN source /home/firedrake/firedrake/bin/activate && \
   pip install -r  DockerRequirements.txt && \
   python -m ipykernel install --user --name=firedrakeDocker
#
# Install x11-apps
RUN sudo apt -y install emacs tcsh
RUN sudo apt -y install x11-apps
# Configure X11 authentication and clean up apt cache
RUN sudo xauth && sudo rm -rf /var/lib/apt/lists/*
# Set timezone to LA
ENV TZ=America/Los_Angeles
RUN sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ | sudo tee /etc/timezone
# Point jupyter config to a custom file (allows port range to changed)
ENV JUPYTER_CONFIG_DIR=~/.jupyter/config_icepack
#
#
# Set up with my user ID and shell preference and allow sudo 
RUN sudo useradd -m -u 3707 ian && echo "ian ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ian
RUN sudo usermod --shell /bin/tcsh ian
RUN sudo usermod -aG sudo ian
RUN  sudo chown -R  ian:ian  /home/firedrake
# Link the firedrake to my home directory
RUN sudo ln -s  /home/firedrake /firedrake
USER ian
# Use docker exec to start shells, so just hold
CMD sleep infinity




