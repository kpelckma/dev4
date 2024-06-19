# part of the FWK
# Makfeile for Yocto integration using docker image fwfwk/yocto:{release}

# -------------------------------------------------
# default variable values
FWK_YOCTO_SRC?=${FWK_TOPDIR}/src/yocto
FWK_YOCTO_DIR?=${FWK_TOPDIR}/prj/yocto
# FWK_YOCTO_DIR?=${ProjectFolder}
FWK_YOCTO_BUILD_DIR?=${FWK_YOCTO_DIR}/build

# FWK_YOCTO_PRE_CFG?=${FWK_TOPDIR}/cfg/yocto_pre.conf
FWK_YOCTO_POST_CFG?=${FWK_TOPDIR}/cfg/yocto_post.conf

FWK_YOCTO_DL_DIR?=${FWK_YOCTO_DIR}/downloads
FWK_YOCTO_SSTATE_DIR?=${FWK_YOCTO_DIR}/sstate-cache

FWK_YOCTO_INIT_BUILD_ENV?=${FWK_YOCTO_SRC}/core/oe-init-build-env
FWK_YOCTO_OE_TERMINAL?="tmux"
#FWK_YOCTO_PRSERV_HOST?="localhost:0"
#FWK_YOCTO_BB_HASHSERV?="localhost:2022"
#FWK_YOCTO_BB_NUMBER_THREADS?="12"

# -------------------------------------------------

# -------------------------------------------------
# docker

# current user information
UID=$(shell id -u)
GID=$(shell id -g)
USERNAME=$(shell id -u -n)
GROUPNAME=$(shell id -g -n)

# set tty for docker if not CI
ifneq (${CI},true)
DOCKER_INT="-it"
endif

ifeq (${FWK_YOCTO_DOCKER_USE},false)
YOCTO_ENV:=source $(FWK_YOCTO_DIR)/bitbake_env.sh &&
else
# docker command
YOCTO_ENV := docker run --rm \
-v ${FWK_TOPDIR}:${FWK_TOPDIR} \
-v ${HOME}/.ssh:/home/${USERNAME}/.ssh \
-v ${FWK_YOCTO_DL_DIR}:${FWK_YOCTO_DL_DIR} \
-v ${FWK_YOCTO_SSTATE_DIR}:${FWK_YOCTO_SSTATE_DIR} \
-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
-e DISPLAY=$(DISPLAY) \
-w ${FWK_TOPDIR} \
${DOCKER_INT} fwfwk/yocto:$(FWK_YOCTO_RELEASE_TAG) \
--source $(FWK_YOCTO_DIR)/bitbake_env.sh \
--create-user \
--uid ${UID} \
--user ${USERNAME} \
--gid ${GID} \
--group ${GROUPNAME}
endif

# -------------------------------------------------
.PHONY: yocto yocto_env yocto_bbappend yocto_build $(FWK_YOCTO_BBAPEND)

# -------------------------------------------------
# create bitbake function with config
# create post config from ENV FWK variables
yocto_env:
  # create default dirs if does not exist
	@$(MKDIR_P) -p $(FWK_YOCTO_DIR)
	@$(MKDIR_P) -p $(FWK_YOCTO_DL_DIR)
	@$(MKDIR_P) -p $(FWK_YOCTO_SSTATE_DIR)
# @echo "# exported config from FWK makefile; !DO NOT EDIT!" > $(FWK_YOCTO_DIR)/local_pre.conf

	@echo "# exported config from FWK makefile; !DO NOT EDIT!" > $(FWK_YOCTO_DIR)/local_post.conf
	@echo "DL_DIR=\"${FWK_YOCTO_DL_DIR}\"" >> $(FWK_YOCTO_DIR)/local_post.conf
	@echo "SSTATE_DIR=\"${FWK_YOCTO_SSTATE_DIR}\"" >> $(FWK_YOCTO_DIR)/local_post.conf
	@echo "OE_TERMINAL=\"${FWK_YOCTO_OE_TERMINAL}\"" >> $(FWK_YOCTO_DIR)/local_post.conf
  ifdef FWK_YOCTO_PRSERV_HOST
	@echo "PRSERV_HOST=\"${FWK_YOCTO_PRSERV_HOST}\"" >> $(FWK_YOCTO_DIR)/local_post.conf
  endif
  ifdef FWK_YOCTO_BB_HASHSERV
	@echo "BB_HASHSERV=\"${FWK_YOCTO_BB_HASHSERV}\"" >> $(FWK_YOCTO_DIR)/local_post.conf
  endif
  ifdef FWK_YOCTO_BB_NUMBER_THREADS
	@echo "BB_NUMBER_THREADS=\"${FWK_YOCTO_BB_NUMBER_THREADS}\"" >> $(FWK_YOCTO_DIR)/local_post.conf
  endif
  ifdef FWK_HDF_PATH
	@echo "HDF_BASE=\"${FWK_HDF_BASE}\"" >> $(FWK_YOCTO_DIR)/local_post.conf
	@echo "HDF_PATH=\"${FWK_HDF_PATH}\"" >> $(FWK_YOCTO_DIR)/local_post.conf
  endif

	@echo "# bitbake enviroment" > $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "function bitbake() { command bitbake \\" > $(FWK_YOCTO_DIR)/bitbake_env.sh
# @echo "--read ${FWK_YOCTO_PRE_CFG} \\" >> $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "--postread ${FWK_YOCTO_POST_CFG}  \\" >> $(FWK_YOCTO_DIR)/bitbake_env.sh
# @echo "--read $(FWK_YOCTO_DIR)/local_pre.conf \\" >> $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "--postread $(FWK_YOCTO_DIR)/local_post.conf  \$$@; };" >> $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "export -f bitbake" >> $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "export HISTFILE=$(FWK_YOCTO_BUILD_DIR)/.bash_history" >> $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "export TEMPLATECONF=${FWK_YOCTO_TEMPLATECONF}" >> $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "export MACHINE=${FWK_YOCTO_MACHINE}" >> $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "source $(FWK_YOCTO_INIT_BUILD_ENV) $(FWK_YOCTO_BUILD_DIR)" >> $(FWK_YOCTO_DIR)/bitbake_env.sh

yocto: yocto_env
	@mkdir -p $(FWK_YOCTO_SRC)
	@mkdir -p out/${ProjectConf}
	cd $(FWK_YOCTO_SRC) && \
	repo init -u $(FWK_YOCTO_MANIFEST_REPO) -m $(FWK_YOCTO_MANIFEST_FILE) -b ${FWK_YOCTO_RELEASE_TAG} && \
	repo sync

yocto_bbappend: $(FWK_YOCTO_BBAPPEND)

$(FWK_YOCTO_BBAPPEND):
	$(YOCTO_ENV) bitbake-layers add-layer $@

yocto_build: yocto_env yocto_bbappend
	$(YOCTO_ENV) bitbake $(FWK_YOCTO_IMAGE)
	$(YOCTO_ENV) bitbake package-index

yocto_bash: yocto_env
	$(YOCTO_ENV) bash

yocto_cleanall: yocto_env
	$(YOCTO_ENV) bitbake $(FWK_YOCTO_IMAGE) -c cleanall

yocto_clean:
	rm -rf $(FWK_YOCTO_BUILD_DIR)

yocto_sdk: yocto_env
	$(YOCTO_ENV) bitbake $(FWK_YOCTO_IMAGE) -c populate_sdk

yocto_sdk_ext: yocto_env
	$(YOCTO_ENV) bitbake $(FWK_YOCTO_IMAGE) -c populate_sdk_ext

