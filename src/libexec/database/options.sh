#
# K2HDKC DBaaS Command Line Interface - K2HR3 CLI Plugin
#
# Copyright 2021 Yahoo! Japan Corporation.
#
# K2HDKC DBaaS is a DataBase as a Service provided by Yahoo! JAPAN
# which is built K2HR3 as a backend and provides services in
# cooperation with OpenStack.
# The Override configuration for K2HDKC DBaaS serves to connect the
# components that make up the K2HDKC DBaaS. K2HDKC, K2HR3, CHMPX,
# and K2HASH are components provided as AntPickax.
#
# For the full copyright and license information, please view
# the license file that was distributed with this source code.
#
# AUTHOR:   Takeshi Nakatani
# CREATE:   Mon Mar 1 2021
# REVISION:
#

#
# Multiple read prevention
#
if [ -n "${K2HR3CLI_DBAAS_OPTION_FILE_LOADED}" ] && [ "${K2HR3CLI_DBAAS_OPTION_FILE_LOADED}" = "1" ]; then
	return 0
fi
K2HR3CLI_DBAAS_OPTION_FILE_LOADED=1

#--------------------------------------------------------------
# DBaaS Options
#--------------------------------------------------------------
K2HR3CLI_COMMAND_OPT_DBAAS_CONFIG_LONG="--dbaas_config"
K2HR3CLI_COMMAND_OPT_DBAAS_SERVER_PORT_LONG="--chmpx_server_port"
K2HR3CLI_COMMAND_OPT_DBAAS_SERVER_CTLPORT_LONG="--chmpx_server_ctlport"
K2HR3CLI_COMMAND_OPT_DBAAS_SLAVE_CTLPORT_LONG="--chmpx_slave_ctlport"
K2HR3CLI_COMMAND_OPT_DBAAS_RUN_USER_LONG="--dbaas_user"
K2HR3CLI_COMMAND_OPT_DBAAS_CREATE_USER_LONG="--dbaas_create_user"
K2HR3CLI_COMMAND_OPT_DBAAS_CREATE_ROLETOKEN_LONG="--create_roletoken"
K2HR3CLI_COMMAND_OPT_OPENSTACK_IDENTITY_URI_LONG="--openstack_identity_uri"
K2HR3CLI_COMMAND_OPT_OPENSTACK_NOVA_URI_LONG="--openstack_nova_uri"
K2HR3CLI_COMMAND_OPT_OPENSTACK_GLANCE_URI_LONG="--openstack_glance_uri"
K2HR3CLI_COMMAND_OPT_OPENSTACK_NEUTRON_URI_LONG="--openstack_neutron_uri"
K2HR3CLI_COMMAND_OPT_OPENSTACK_USER_LONG="--op_user"
K2HR3CLI_COMMAND_OPT_OPENSTACK_PASS_LONG="--op_passphrase"
K2HR3CLI_COMMAND_OPT_OPENSTACK_TENANT_LONG="--op_tenant"
K2HR3CLI_COMMAND_OPT_OPENSTACK_NO_SECGRP_LONG="--op_no_secgrp"
K2HR3CLI_COMMAND_OPT_OPENSTACK_KEYPAIR_LONG="--op_keypair"
K2HR3CLI_COMMAND_OPT_OPENSTACK_FLAVOR_LONG="--op_flavor"
K2HR3CLI_COMMAND_OPT_OPENSTACK_FLAVOR_ID_LONG="--op_flavor_id"
K2HR3CLI_COMMAND_OPT_OPENSTACK_IMAGE_LONG="--op_image"
K2HR3CLI_COMMAND_OPT_OPENSTACK_IMAGE_ID_LONG="--op_image_id"
K2HR3CLI_COMMAND_OPT_OPENSTACK_BLOCKDEVICE_LONG="--op_block_device"
K2HR3CLI_COMMAND_OPT_OPENSTACK_CONFIRM_YES_SHORT="-y"
K2HR3CLI_COMMAND_OPT_OPENSTACK_CONFIRM_YES_LONG="--yes"

#
# Default value
#
K2HR3CLI_COMMAND_OPT_DBAAS_DEFALT_SERVER_PORT=8020
K2HR3CLI_COMMAND_OPT_DBAAS_DEFALT_SERVER_CTLPORT=8021
K2HR3CLI_COMMAND_OPT_DBAAS_DEFALT_SLAVE_CTLPORT=8031

#
# Parse common option
#
# $@									option strings
#
# $?									returns 1 for fatal errors
# Set global values
#	K2HR3CLI_OPTION_PARSER_REST			: the remaining option string with the help option cut off(for new $@)
#	K2HR3CLI_DBAAS_CONFIG				: --dbaas_config
#	K2HR3CLI_OPT_DBAAS_SERVER_PORT		: --chmpx_server_port
#	K2HR3CLI_OPT_DBAAS_SERVER_CTLPORT	: --chmpx_server_ctlport
#	K2HR3CLI_OPT_DBAAS_SLAVE_CTLPORT	: --chmpx_slave_ctlport
#	K2HR3CLI_OPT_DBAAS_RUN_USER			: --dbaas_user
#	K2HR3CLI_OPT_DBAAS_CREATE_USER		: --dbaas_create_user
#	K2HR3CLI_OPT_DBAAS_CREATE_ROLETOKEN	: --create_roletoken
#	K2HR3CLI_OPENSTACK_IDENTITY_URI		: --openstack_identity_uri
#	K2HR3CLI_OPENSTACK_NOVA_URI			: --openstack_nova_uri
#	K2HR3CLI_OPENSTACK_GLANCE_URI		: --openstack_glance_uri
#	K2HR3CLI_OPENSTACK_NEUTRON_URI		: --openstack_neutron_uri
#	K2HR3CLI_OPENSTACK_USER				: --op_user
#	K2HR3CLI_OPENSTACK_PASS				: --op_passphrase
#	K2HR3CLI_OPENSTACK_TENANT			: --op_tenant
#	K2HR3CLI_OPENSTACK_NO_SECGRP		: --op_no_secgrp
#	K2HR3CLI_OPENSTACK_KEYPAIR			: --op_keypair
#	K2HR3CLI_OPENSTACK_FLAVOR			: --op_flavor
#	K2HR3CLI_OPENSTACK_FLAVOR_ID		: --op_flavor_id
#	K2HR3CLI_OPENSTACK_IMAGE			: --op_image
#	K2HR3CLI_OPENSTACK_IMAGE_ID			: --op_image_id
#	K2HR3CLI_OPENSTACK_BCLOKDEVICE		: --op_block_device
#	K2HR3CLI_OPENSTACK_CONFIRM_YES		: --yes(-y)
#
parse_dbaas_option()
{
	#
	# Temporary values
	#
	_OPT_TMP_DBAAS_CONFIG=
	_OPT_TMP_DBAAS_SERVER_PORT=
	_OPT_TMP_DBAAS_SERVER_CTLPORT=
	_OPT_TMP_DBAAS_SLAVE_CTLPORT=
	_OPT_TMP_DBAAS_RUN_USER=
	_OPT_TMP_DBAAS_CREATE_USER=
	_OPT_TMP_DBAAS_CREATE_ROLETOKEN=
	_OPT_TMP_DBAAS_OPENSTACK_IDENTITY_URI=
	_OPT_TMP_DBAAS_OPENSTACK_NOVA_URI=
	_OPT_TMP_DBAAS_OPENSTACK_GLANCE_URI=
	_OPT_TMP_DBAAS_OPENSTACK_NEUTRON_URI=
	_OPT_TMP_DBAAS_OPENSTACK_USER=
	_OPT_TMP_DBAAS_OPENSTACK_PASS=
	_OPT_TMP_DBAAS_OPENSTACK_TENANT=
	_OPT_TMP_DBAAS_OPENSTACK_NO_SECGRP=
	_OPT_TMP_DBAAS_OPENSTACK_KEYPAIR=
	_OPT_TMP_DBAAS_OPENSTACK_FLAVOR=
	_OPT_TMP_DBAAS_OPENSTACK_FLAVOR_ID=
	_OPT_TMP_DBAAS_OPENSTACK_IMAGE=
	_OPT_TMP_DBAAS_OPENSTACK_IMAGE_ID=
	_OPT_TMP_DBAAS_OPENSTACK_BLOCKDEVICE=
	_OPT_TMP_DBAAS_OPENSTACK_CONFIRM_YES=

	K2HR3CLI_OPTION_PARSER_REST=""
	while [ $# -gt 0 ]; do
		_OPTION_TMP=$(to_lower "$1")

		if [ -z "${_OPTION_TMP}" ]; then
			if [ -z "${K2HR3CLI_OPTION_PARSER_REST}" ]; then
				K2HR3CLI_OPTION_PARSER_REST="$1"
			else
				K2HR3CLI_OPTION_PARSER_REST="${K2HR3CLI_OPTION_PARSER_REST} $1"
			fi

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_DBAAS_CONFIG_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_CONFIG}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_DBAAS_CONFIG_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DBAAS_CONFIG_LONG} option needs parameter."
				return 1
			fi
			if [ ! -d "$1" ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DBAAS_CONFIG_LONG} option parameter($1) directory does not exist."
				return 1
			fi
			_OPT_TMP_DBAAS_CONFIG=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_DBAAS_SERVER_PORT_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_SERVER_PORT}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_DBAAS_SERVER_PORT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DBAAS_SERVER_PORT_LONG} option needs parameter."
				return 1
			fi
			if ! is_positive_number "$1"; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DBAAS_SERVER_PORT_LONG} option parameter must be 0 or positive number."
				return 1
			fi
			if [ "$1" -eq 0 ]; then
				_OPT_TMP_DBAAS_SERVER_PORT="${K2HR3CLI_COMMAND_OPT_DBAAS_DEFALT_SERVER_PORT}"
			else
				_OPT_TMP_DBAAS_SERVER_PORT="$1"
			fi

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_DBAAS_SERVER_CTLPORT_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_SERVER_CTLPORT}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_DBAAS_SERVER_CTLPORT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DBAAS_SERVER_CTLPORT_LONG} option needs parameter."
				return 1
			fi
			if ! is_positive_number "$1"; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DBAAS_SERVER_CTLPORT_LONG} option parameter must be 0 or positive number."
				return 1
			fi
			if [ "$1" -eq 0 ]; then
				_OPT_TMP_DBAAS_SERVER_CTLPORT="${K2HR3CLI_COMMAND_OPT_DBAAS_DEFALT_SERVER_CTLPORT}"
			else
				_OPT_TMP_DBAAS_SERVER_CTLPORT="$1"
			fi

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_DBAAS_SLAVE_CTLPORT_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_SLAVE_CTLPORT}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_DBAAS_SLAVE_CTLPORT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DBAAS_SLAVE_CTLPORT_LONG} option needs parameter."
				return 1
			fi
			if ! is_positive_number "$1"; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DBAAS_SLAVE_CTLPORT_LONG} option parameter must be 0 or positive number."
				return 1
			fi
			if [ "$1" -eq 0 ]; then
				_OPT_TMP_DBAAS_SLAVE_CTLPORT="${K2HR3CLI_COMMAND_OPT_DBAAS_DEFALT_SLAVE_CTLPORT}"
			else
				_OPT_TMP_DBAAS_SLAVE_CTLPORT="$1"
			fi

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_DBAAS_RUN_USER_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_RUN_USER}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_DBAAS_RUN_USER_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DBAAS_RUN_USER_LONG} option needs parameter."
				return 1
			fi
			_OPTION_TMP_VAL=$(echo "$1" | grep -v "[^a-zA-Z0-9_]")
			if [ -z "${_OPTION_TMP_VAL}" ]; then
				prn_err "Invalid username specified with ${K2HR3CLI_COMMAND_OPT_DBAAS_RUN_USER_LONG} option."
				return 1
			fi
			_OPT_TMP_DBAAS_RUN_USER="$1"

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_DBAAS_CREATE_USER_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_CREATE_USER}" ]; then
				prn_err "already specified K2HR3CLI_COMMAND_OPT_DBAAS_CREATE_USER_LONG option."
				return 1
			fi
			_OPT_TMP_DBAAS_CREATE_USER=1

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_IDENTITY_URI_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_IDENTITY_URI}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_IDENTITY_URI_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_IDENTITY_URI_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_IDENTITY_URI=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_IDENTITY_URI=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_IDENTITY_URI}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_NOVA_URI_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_NOVA_URI}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_NOVA_URI_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_NOVA_URI_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_NOVA_URI=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_NOVA_URI=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_NOVA_URI}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_GLANCE_URI_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_GLANCE_URI}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_GLANCE_URI_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_GLANCE_URI_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_GLANCE_URI=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_GLANCE_URI=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_GLANCE_URI}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_NEUTRON_URI_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_NEUTRON_URI}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_NEUTRON_URI_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_NEUTRON_URI_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_NEUTRON_URI=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_NEUTRON_URI=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_NEUTRON_URI}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_DBAAS_CREATE_ROLETOKEN_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_CREATE_ROLETOKEN}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_DBAAS_CREATE_ROLETOKEN_LONG} option."
				return 1
			fi
			_OPT_TMP_DBAAS_CREATE_ROLETOKEN=1

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_USER_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_USER}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_USER_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_USER_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_USER=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_USER=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_USER}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_PASS_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_PASS}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_PASS_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_PASS_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_PASS=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_PASS=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_PASS}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_TENANT_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_TENANT}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_TENANT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_TENANT_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_TENANT=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_TENANT=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_TENANT}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_NO_SECGRP_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_NO_SECGRP}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_NO_SECGRP_LONG} option."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_NO_SECGRP=1

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_KEYPAIR_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_KEYPAIR}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_KEYPAIR_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_KEYPAIR_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_KEYPAIR=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_KEYPAIR=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_KEYPAIR}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_FLAVOR_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_FLAVOR}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_FLAVOR_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_FLAVOR_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_FLAVOR=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_FLAVOR=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_FLAVOR}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_FLAVOR_ID_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_FLAVOR_ID}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_FLAVOR_ID_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_FLAVOR_ID_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_FLAVOR_ID=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_FLAVOR_ID=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_FLAVOR_ID}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_IMAGE_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_IMAGE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_IMAGE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_IMAGE_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_IMAGE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_IMAGE=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_IMAGE}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_IMAGE_ID_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_IMAGE_ID}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_IMAGE_ID_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_IMAGE_ID_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_IMAGE_ID=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
			_OPT_TMP_DBAAS_OPENSTACK_IMAGE_ID=$(filter_null_string "${_OPT_TMP_DBAAS_OPENSTACK_IMAGE_ID}")

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_BLOCKDEVICE_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_BLOCKDEVICE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_BLOCKDEVICE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_BLOCKDEVICE_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_BLOCKDEVICE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_CONFIRM_YES_LONG}" ] || [ "${_OPTION_TMP}" = "${K2HR3CLI_COMMAND_OPT_OPENSTACK_CONFIRM_YES_SHORT}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_CONFIRM_YES}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_CONFIRM_YES_LONG}(${K2HR3CLI_COMMAND_OPT_OPENSTACK_CONFIRM_YES_SHORT}) option."
				return 1
			fi
			_OPT_TMP_DBAAS_OPENSTACK_CONFIRM_YES=1

		else
			if [ -z "${K2HR3CLI_OPTION_PARSER_REST}" ]; then
				K2HR3CLI_OPTION_PARSER_REST="$1"
			else
				K2HR3CLI_OPTION_PARSER_REST="${K2HR3CLI_OPTION_PARSER_REST} $1"
			fi
		fi
		shift
	done

	#
	# Set override default and global value
	#
	if [ -n "${_OPT_TMP_DBAAS_CONFIG}" ]; then
		K2HR3CLI_DBAAS_CONFIG=${_OPT_TMP_DBAAS_CONFIG}
	fi
	if [ -n "${_OPT_TMP_DBAAS_SERVER_PORT}" ]; then
		K2HR3CLI_OPT_DBAAS_SERVER_PORT=${_OPT_TMP_DBAAS_SERVER_PORT}
	else
		K2HR3CLI_OPT_DBAAS_SERVER_PORT=${K2HR3CLI_COMMAND_OPT_DBAAS_DEFALT_SERVER_PORT}
	fi
	if [ -n "${_OPT_TMP_DBAAS_SERVER_CTLPORT}" ]; then
		K2HR3CLI_OPT_DBAAS_SERVER_CTLPORT=${_OPT_TMP_DBAAS_SERVER_CTLPORT}
	else
		K2HR3CLI_OPT_DBAAS_SERVER_CTLPORT=${K2HR3CLI_COMMAND_OPT_DBAAS_DEFALT_SERVER_CTLPORT}
	fi
	if [ -n "${_OPT_TMP_DBAAS_SLAVE_CTLPORT}" ]; then
		K2HR3CLI_OPT_DBAAS_SLAVE_CTLPORT=${_OPT_TMP_DBAAS_SLAVE_CTLPORT}
	else
		K2HR3CLI_OPT_DBAAS_SLAVE_CTLPORT=${K2HR3CLI_COMMAND_OPT_DBAAS_DEFALT_SLAVE_CTLPORT}
	fi
	if [ -n "${_OPT_TMP_DBAAS_RUN_USER}" ]; then
		K2HR3CLI_OPT_DBAAS_RUN_USER=${_OPT_TMP_DBAAS_RUN_USER}
	else
		K2HR3CLI_OPT_DBAAS_RUN_USER=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_CREATE_USER}" ]; then
		K2HR3CLI_OPT_DBAAS_CREATE_USER=${_OPT_TMP_DBAAS_CREATE_USER}
	else
		K2HR3CLI_OPT_DBAAS_CREATE_USER=0
	fi
	if [ -n "${_OPT_TMP_DBAAS_CREATE_ROLETOKEN}" ]; then
		K2HR3CLI_OPT_DBAAS_CREATE_ROLETOKEN=${_OPT_TMP_DBAAS_CREATE_ROLETOKEN}
	else
		K2HR3CLI_OPT_DBAAS_CREATE_ROLETOKEN=0
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_IDENTITY_URI}" ]; then
		if [ -z "${K2HR3CLI_OPENSTACK_IDENTITY_URI}" ] || [ "${K2HR3CLI_OPENSTACK_IDENTITY_URI}" != "${_OPT_TMP_DBAAS_OPENSTACK_IDENTITY_URI}" ]; then
			add_config_update_var "K2HR3CLI_OPENSTACK_IDENTITY_URI"
		fi
		K2HR3CLI_OPENSTACK_IDENTITY_URI=${_OPT_TMP_DBAAS_OPENSTACK_IDENTITY_URI}
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_NOVA_URI}" ]; then
		if [ -z "${K2HR3CLI_OPENSTACK_NOVA_URI}" ] || [ "${K2HR3CLI_OPENSTACK_NOVA_URI}" != "${_OPT_TMP_DBAAS_OPENSTACK_NOVA_URI}" ]; then
			add_config_update_var "K2HR3CLI_OPENSTACK_NOVA_URI"
		fi
		K2HR3CLI_OPENSTACK_NOVA_URI=${_OPT_TMP_DBAAS_OPENSTACK_NOVA_URI}
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_GLANCE_URI}" ]; then
		if [ -z "${K2HR3CLI_OPENSTACK_GLANCE_URI}" ] || [ "${K2HR3CLI_OPENSTACK_GLANCE_URI}" != "${_OPT_TMP_DBAAS_OPENSTACK_GLANCE_URI}" ]; then
			add_config_update_var "K2HR3CLI_OPENSTACK_GLANCE_URI"
		fi
		K2HR3CLI_OPENSTACK_GLANCE_URI=${_OPT_TMP_DBAAS_OPENSTACK_GLANCE_URI}
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_NEUTRON_URI}" ]; then
		if [ -z "${K2HR3CLI_OPENSTACK_NEUTRON_URI}" ] || [ "${K2HR3CLI_OPENSTACK_NEUTRON_URI}" != "${_OPT_TMP_DBAAS_OPENSTACK_NEUTRON_URI}" ]; then
			add_config_update_var "K2HR3CLI_OPENSTACK_NEUTRON_URI"
		fi
		K2HR3CLI_OPENSTACK_NEUTRON_URI=${_OPT_TMP_DBAAS_OPENSTACK_NEUTRON_URI}
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_USER}" ]; then
		K2HR3CLI_OPENSTACK_USER=${_OPT_TMP_DBAAS_OPENSTACK_USER}
		K2HR3CLI_OPENSTACK_USER_ID=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_PASS}" ]; then
		K2HR3CLI_OPENSTACK_PASS=${_OPT_TMP_DBAAS_OPENSTACK_PASS}
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_TENANT}" ]; then
		K2HR3CLI_OPENSTACK_TENANT=${_OPT_TMP_DBAAS_OPENSTACK_TENANT}
		K2HR3CLI_OPENSTACK_TENANT_ID=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_NO_SECGRP}" ]; then
		K2HR3CLI_OPENSTACK_NO_SECGRP=${_OPT_TMP_DBAAS_OPENSTACK_NO_SECGRP}
	else
		K2HR3CLI_OPENSTACK_NO_SECGRP=0
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_KEYPAIR}" ]; then
		K2HR3CLI_OPENSTACK_KEYPAIR=${_OPT_TMP_DBAAS_OPENSTACK_KEYPAIR}
	else
		K2HR3CLI_OPENSTACK_KEYPAIR=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_FLAVOR}" ]; then
		K2HR3CLI_OPENSTACK_FLAVOR=${_OPT_TMP_DBAAS_OPENSTACK_FLAVOR}
	else
		K2HR3CLI_OPENSTACK_FLAVOR=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_FLAVOR_ID}" ]; then
		K2HR3CLI_OPENSTACK_FLAVOR_ID=${_OPT_TMP_DBAAS_OPENSTACK_FLAVOR_ID}
	else
		K2HR3CLI_OPENSTACK_FLAVOR_ID=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_IMAGE}" ]; then
		K2HR3CLI_OPENSTACK_IMAGE=${_OPT_TMP_DBAAS_OPENSTACK_IMAGE}
	else
		K2HR3CLI_OPENSTACK_IMAGE=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_IMAGE_ID}" ]; then
		K2HR3CLI_OPENSTACK_IMAGE_ID=${_OPT_TMP_DBAAS_OPENSTACK_IMAGE_ID}
	else
		K2HR3CLI_OPENSTACK_IMAGE_ID=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_BLOCKDEVICE}" ]; then
		K2HR3CLI_OPENSTACK_BCLOKDEVICE=${_OPT_TMP_DBAAS_OPENSTACK_BLOCKDEVICE}
	else
		K2HR3CLI_OPENSTACK_BCLOKDEVICE=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_OPENSTACK_CONFIRM_YES}" ]; then
		K2HR3CLI_OPENSTACK_CONFIRM_YES=${_OPT_TMP_DBAAS_OPENSTACK_CONFIRM_YES}
	else
		K2HR3CLI_OPENSTACK_CONFIRM_YES=0
	fi

	#
	# Check special variable(K2HR3CLI_OPENSTACK_{IDENTITY,NOVA,GLANCE,NEUTRON}_URI)
	#
	# Cut last word if it is '/' and space
	#
	if [ -n "${K2HR3CLI_OPENSTACK_IDENTITY_URI}" ]; then
		for _OPT_TMP_URI_POS in $(seq 0 ${#K2HR3CLI_OPENSTACK_IDENTITY_URI}); do
			_OPT_TMP_URI_LAST_POS=$((${#K2HR3CLI_OPENSTACK_IDENTITY_URI} - _OPT_TMP_URI_POS))
			if [ "${_OPT_TMP_URI_LAST_POS}" -le 0 ]; then
				break
			fi
			_OPT_TMP_URI_LAST_CH=$(pecho -n "${K2HR3CLI_OPENSTACK_IDENTITY_URI}" | cut -b "${_OPT_TMP_URI_LAST_POS}")
			if [ -n "${_OPT_TMP_URI_LAST_CH}" ] && { [ "${_OPT_TMP_URI_LAST_CH}" = "/" ] || [ "${_OPT_TMP_URI_LAST_CH}" = " " ] || [ "${_OPT_TMP_URI_LAST_CH}" = "${K2HR3CLI_TAB_WORD}" ]; }; then
				if [ "${_OPT_TMP_URI_LAST_POS}" -gt 1 ]; then
					_OPT_TMP_URI_LAST_POS=$((_OPT_TMP_URI_LAST_POS - 1))
					K2HR3CLI_OPENSTACK_IDENTITY_URI=$(pecho -n "${K2HR3CLI_OPENSTACK_IDENTITY_URI}" | cut -c 1-"${_OPT_TMP_URI_LAST_POS}")
				else
					K2HR3CLI_OPENSTACK_IDENTITY_URI=""
					break;
				fi
			else
				break
			fi
		done
	fi
	if [ -n "${K2HR3CLI_OPENSTACK_NOVA_URI}" ]; then
		for _OPT_TMP_URI_POS in $(seq 0 ${#K2HR3CLI_OPENSTACK_NOVA_URI}); do
			_OPT_TMP_URI_LAST_POS=$((${#K2HR3CLI_OPENSTACK_NOVA_URI} - _OPT_TMP_URI_POS))
			if [ "${_OPT_TMP_URI_LAST_POS}" -le 0 ]; then
				break
			fi
			_OPT_TMP_URI_LAST_CH=$(pecho -n "${K2HR3CLI_OPENSTACK_NOVA_URI}" | cut -b "${_OPT_TMP_URI_LAST_POS}")
			if [ -n "${_OPT_TMP_URI_LAST_CH}" ] && { [ "${_OPT_TMP_URI_LAST_CH}" = "/" ] || [ "${_OPT_TMP_URI_LAST_CH}" = " " ] || [ "${_OPT_TMP_URI_LAST_CH}" = "${K2HR3CLI_TAB_WORD}" ]; }; then
				if [ "${_OPT_TMP_URI_LAST_POS}" -gt 1 ]; then
					_OPT_TMP_URI_LAST_POS=$((_OPT_TMP_URI_LAST_POS - 1))
					K2HR3CLI_OPENSTACK_NOVA_URI=$(pecho -n "${K2HR3CLI_OPENSTACK_NOVA_URI}" | cut -c 1-"${_OPT_TMP_URI_LAST_POS}")
				else
					K2HR3CLI_OPENSTACK_NOVA_URI=""
					break;
				fi
			else
				break
			fi
		done
	fi
	if [ -n "${K2HR3CLI_OPENSTACK_GLANCE_URI}" ]; then
		for _OPT_TMP_URI_POS in $(seq 0 ${#K2HR3CLI_OPENSTACK_GLANCE_URI}); do
			_OPT_TMP_URI_LAST_POS=$((${#K2HR3CLI_OPENSTACK_GLANCE_URI} - _OPT_TMP_URI_POS))
			if [ "${_OPT_TMP_URI_LAST_POS}" -le 0 ]; then
				break
			fi
			_OPT_TMP_URI_LAST_CH=$(pecho -n "${K2HR3CLI_OPENSTACK_GLANCE_URI}" | cut -b "${_OPT_TMP_URI_LAST_POS}")
			if [ -n "${_OPT_TMP_URI_LAST_CH}" ] && { [ "${_OPT_TMP_URI_LAST_CH}" = "/" ] || [ "${_OPT_TMP_URI_LAST_CH}" = " " ] || [ "${_OPT_TMP_URI_LAST_CH}" = "${K2HR3CLI_TAB_WORD}" ]; }; then
				if [ "${_OPT_TMP_URI_LAST_POS}" -gt 1 ]; then
					_OPT_TMP_URI_LAST_POS=$((_OPT_TMP_URI_LAST_POS - 1))
					K2HR3CLI_OPENSTACK_GLANCE_URI=$(pecho -n "${K2HR3CLI_OPENSTACK_GLANCE_URI}" | cut -c 1-"${_OPT_TMP_URI_LAST_POS}")
				else
					K2HR3CLI_OPENSTACK_GLANCE_URI=""
					break;
				fi
			else
				break
			fi
		done
	fi
	if [ -n "${K2HR3CLI_OPENSTACK_NEUTRON_URI}" ]; then
		for _OPT_TMP_URI_POS in $(seq 0 ${#K2HR3CLI_OPENSTACK_NEUTRON_URI}); do
			_OPT_TMP_URI_LAST_POS=$((${#K2HR3CLI_OPENSTACK_NEUTRON_URI} - _OPT_TMP_URI_POS))
			if [ "${_OPT_TMP_URI_LAST_POS}" -le 0 ]; then
				break
			fi
			_OPT_TMP_URI_LAST_CH=$(pecho -n "${K2HR3CLI_OPENSTACK_NEUTRON_URI}" | cut -b "${_OPT_TMP_URI_LAST_POS}")
			if [ -n "${_OPT_TMP_URI_LAST_CH}" ] && { [ "${_OPT_TMP_URI_LAST_CH}" = "/" ] || [ "${_OPT_TMP_URI_LAST_CH}" = " " ] || [ "${_OPT_TMP_URI_LAST_CH}" = "${K2HR3CLI_TAB_WORD}" ]; }; then
				if [ "${_OPT_TMP_URI_LAST_POS}" -gt 1 ]; then
					_OPT_TMP_URI_LAST_POS=$((_OPT_TMP_URI_LAST_POS - 1))
					K2HR3CLI_OPENSTACK_NEUTRON_URI=$(pecho -n "${K2HR3CLI_OPENSTACK_NEUTRON_URI}" | cut -c 1-"${_OPT_TMP_URI_LAST_POS}")
				else
					K2HR3CLI_OPENSTACK_NEUTRON_URI=""
					break;
				fi
			else
				break
			fi
		done
	fi

	return 0
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
