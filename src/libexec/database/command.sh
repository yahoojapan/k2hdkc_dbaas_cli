#
# K2HDKC DBaaS Command Line Interface - K2HR3 CLI Plugin
#
# Copyright 2021 Yahoo Japan Corporation.
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

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
#
# k2hr3 bin
#
K2HR3CLIBIN=${BINDIR}/${BINNAME}

#
# Directry Path
#
_DATABASE_CURRENT_DIR=${LIBEXECDIR}/${K2HR3CLI_MODE}

#
# SubCommand(2'nd option)
#
_DATABASE_COMMAND_SUB_CREATE="create"
_DATABASE_COMMAND_SUB_SHOW="show"
_DATABASE_COMMAND_SUB_ADD="add"
_DATABASE_COMMAND_SUB_DELETE="delete"
_DATABASE_COMMAND_SUB_OPENSTACK="openstack"
_DATABASE_COMMAND_SUB_LIST="list"

#
# option for type
#
_DATABASE_COMMAND_TYPE_HOST="host"
_DATABASE_COMMAND_TYPE_CONF="conf"
_DATABASE_COMMAND_TYPE_CONF_LONG="configuration"
_DATABASE_COMMAND_TYPE_CLUSTER="cluster"
_DATABASE_COMMAND_TYPE_OPUTOKEN="utoken"
_DATABASE_COMMAND_TYPE_OPTOKEN="token"
_DATABASE_COMMAND_TYPE_IMAGES="images"
_DATABASE_COMMAND_TYPE_FLAVORS="flavors"

#
# option for target
#
_DATABASE_COMMAND_TARGET_SERVER="server"
_DATABASE_COMMAND_TARGET_SLAVE="slave"

#--------------------------------------------------------------
# Load Option name for DBaaS
#--------------------------------------------------------------
#
# DBaaS option
#
if [ -f "${LIBEXECDIR}/database/options.sh" ]; then
	. "${LIBEXECDIR}/database/options.sh"
fi

#
# Utility functions
#
if [ -f "${LIBEXECDIR}/database/functions.sh" ]; then
	. "${LIBEXECDIR}/database/functions.sh"
fi

#
# OpenStack utility
#
if [ -f "${LIBEXECDIR}/database/openstack.sh" ]; then
	. "${LIBEXECDIR}/database/openstack.sh"
fi

#
# Check dbaas options
#
if ! parse_dbaas_option "$@"; then
	exit 1
else
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}
fi

#--------------------------------------------------------------
# Parse arguments
#--------------------------------------------------------------
#
# Sub Command
#
if ! parse_noprefix_option "$@"; then
	exit 1
fi
if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
	K2HR3CLI_SUBCOMMAND=""
else
	#
	# Always using lower case
	#
	K2HR3CLI_SUBCOMMAND=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
fi
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#
# After sub command
#
if [ -n "${K2HR3CLI_SUBCOMMAND}" ] && [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_CREATE}" ]; then
	#
	# Create Cluster(cluster name)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_CLUSTER_NAME=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_CLUSTER_NAME=${K2HR3CLI_OPTION_NOPREFIX}
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}

elif [ -n "${K2HR3CLI_SUBCOMMAND}" ] && [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_SHOW}" ]; then
	#
	# Show host/configuration(type)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_SHOW_TYPE=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_SHOW_TYPE=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}

	#
	# Show host/configuration(target)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_SHOW_TARGET=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_SHOW_TARGET=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}

	#
	# Show host/configuration(cluster name)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_CLUSTER_NAME=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_CLUSTER_NAME=${K2HR3CLI_OPTION_NOPREFIX}
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}

elif [ -n "${K2HR3CLI_SUBCOMMAND}" ] && [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_ADD}" ]; then
	#
	# Add host(type)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_ADD_TYPE=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_ADD_TYPE=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}

	#
	# Add host(target)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_ADD_TARGET=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_ADD_TARGET=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}

	#
	# Add host(cluster name)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_CLUSTER_NAME=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_CLUSTER_NAME=${K2HR3CLI_OPTION_NOPREFIX}
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}

	#
	# Add host(hostname)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_HOST_NAME=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_HOST_NAME=${K2HR3CLI_OPTION_NOPREFIX}
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}


elif [ -n "${K2HR3CLI_SUBCOMMAND}" ] && [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_DELETE}" ]; then
	#
	# Delete host/cluster(type)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_DELETE_TYPE=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_DELETE_TYPE=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}

	#
	# Delete host/cluster(cluster name)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_CLUSTER_NAME=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_CLUSTER_NAME=${K2HR3CLI_OPTION_NOPREFIX}
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}

	if [ -n "${K2HR3CLI_DBAAS_DELETE_TYPE}" ] && [ "${K2HR3CLI_DBAAS_DELETE_TYPE}" = "${_DATABASE_COMMAND_TYPE_HOST}" ]; then
		#
		# Delete host(hostname)
		#
		if ! parse_noprefix_option "$@"; then
			exit 1
		fi
		if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
			K2HR3CLI_DBAAS_HOST_NAME=""
		else
			#
			# Always using lower case
			#
			K2HR3CLI_DBAAS_HOST_NAME=${K2HR3CLI_OPTION_NOPREFIX}
		fi
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}
	fi

elif [ -n "${K2HR3CLI_SUBCOMMAND}" ] && [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_OPENSTACK}" ]; then
	#
	# OpenStack (type)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_OPENSTACK_TYPE=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_OPENSTACK_TYPE=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}


elif [ -n "${K2HR3CLI_SUBCOMMAND}" ] && [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_LIST}" ]; then
	#
	# List (type)
	#
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		K2HR3CLI_DBAAS_LIST_TYPE=""
	else
		#
		# Always using lower case
		#
		K2HR3CLI_DBAAS_LIST_TYPE=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}
fi

#--------------------------------------------------------------
# Processing
#--------------------------------------------------------------
#
# Check URI
#
if [ -z "${K2HR3CLI_OPENSTACK_IDENTITY_URI}" ]; then
	prn_warn "The URI for OpenStack(Identity) is not specified, some commands require this. Please specify with the ${K2HR3CLI_COMMAND_OPT_OPENSTACK_IDENTITY_URI_LONG} option, K2HR3CLI_OPENSTACK_IDENTITY_URI environment variable, or configuration."
fi

#
# Check Cluster name parameter
#
if [ -z "${K2HR3CLI_SUBCOMMAND}" ] || { [ "${K2HR3CLI_SUBCOMMAND}" != "${_DATABASE_COMMAND_SUB_OPENSTACK}" ] &&  [ "${K2HR3CLI_SUBCOMMAND}" != "${_DATABASE_COMMAND_SUB_LIST}" ]; }; then
	if [ -z "${K2HR3CLI_DBAAS_CLUSTER_NAME}" ]; then
		prn_err "Cluster name is not specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
fi

#
# Main
#
if [ -z "${K2HR3CLI_SUBCOMMAND}" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must also specify the subcommand(${_DATABASE_COMMAND_SUB_CREATE}, ${_DATABASE_COMMAND_SUB_SHOW}, ${_DATABASE_COMMAND_SUB_ADD} or ${_DATABASE_COMMAND_SUB_DELETE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_CREATE}" ]; then
	#
	# DATABASE CREATE
	#

	#
	# Get Scoped Token
	#
	if ! complement_scoped_token; then
		exit 1
	fi
	prn_dbg "${K2HR3CLI_SCOPED_TOKEN}"

	#
	# Create new token
	#
	if ! complement_op_token; then
		prn_err "Failed to create OpenStack Scoped Token"
		exit 1
	fi

	#
	# Get resource template file path
	#
	if ! dbaas_get_resource_filepath; then
		exit 1
	fi

	#
	# Get Tenant name from Scoped Token
	#
	if ! _DATABASE_TENANT_NAME=$(dbaas_get_current_tenant); then
		exit 1
	fi

	#------------------------------------------------------
	# Create Main Resource
	#------------------------------------------------------
	#
	# Make String Resource/Keys Paramter
	#
	_DATABASE_CONFIG_FILE_TMP="/tmp/.k2hdkc_dbaas_resource_$$.templ"
	_DATABASE_RESOURCE_DATE=$(date)
	sed -e "s/__K2HDKC_DBAAS_CLI_DATE__/${_DATABASE_RESOURCE_DATE}/g" -e "s/__K2HDKC_DBAAS_CLI_TENANT_NAME__/${_DATABASE_TENANT_NAME}/g" -e "s/__K2HDKC_DBAAS_CLI_CLUSTER_NAME__/${K2HR3CLI_DBAAS_CLUSTER_NAME}/g" "${_DATABASE_CONFIG_FILE}" > "${_DATABASE_CONFIG_FILE_TMP}" 2>/dev/null

	#
	# Make resource keys data
	#
	_DATABASE_RESOURCE_KEYS_RUN_USER=""
	if [ -n "${K2HR3CLI_OPT_DBAAS_RUN_USER}" ]; then
		_DATABASE_RESOURCE_KEYS_RUN_USER=",\"k2hdkc-dbaas-proc-user\":\"${K2HR3CLI_OPT_DBAAS_RUN_USER}\""
	fi
	if [ -n "${K2HR3CLI_OPT_DBAAS_CREATE_USER}" ] && [ "${K2HR3CLI_OPT_DBAAS_CREATE_USER}" = "1" ]; then
		_DATABASE_RESOURCE_KEYS_RUN_USER="${_DATABASE_RESOURCE_KEYS_RUN_USER},\"k2hdkc-dbaas-add-user\":1"
	fi
	_DATABASE_RESOURCE_KEYS="{\"cluster-name\":\"${K2HR3CLI_DBAAS_CLUSTER_NAME}\",\"chmpx-server-port\":${K2HR3CLI_OPT_DBAAS_SERVER_PORT},\"chmpx-server-ctlport\":${K2HR3CLI_OPT_DBAAS_SERVER_CTLPORT},\"chmpx-slave-ctlport\":${K2HR3CLI_OPT_DBAAS_SLAVE_CTLPORT}${_DATABASE_RESOURCE_KEYS_RUN_USER}}"

	#
	# Run k2hr3
	#
	if ! K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
		"${K2HR3CLIBIN}" resource create "${K2HR3CLI_DBAAS_CLUSTER_NAME}" -type string --datafile "${_DATABASE_CONFIG_FILE_TMP}" --keys "${_DATABASE_RESOURCE_KEYS}" > /dev/null; then

		prn_msg "${CRED}Failed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}\""
		rm -f "${_DATABASE_CONFIG_FILE_TMP}"
		exit 1
	fi
	prn_msg "${CGRN}Succeed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}\" Resource"
	rm -f "${_DATABASE_CONFIG_FILE_TMP}"

	#------------------------------------------------------
	# Create Sub Server/Slave Resource
	#------------------------------------------------------
	#
	# Load keys data
	#
	if ! dbaas_load_resource_keys; then
		exit 1
	fi

	#
	# Make Keys Paramter for server
	#
	_DATABASE_RESOURCE_SERVER_KEYS="{\"chmpx-mode\":\"SERVER\",\"k2hr3-init-packages\":\"${DATABASE_SERVER_KEY_INI_PKG}\",\"k2hr3-init-packagecloud-packages\":\"${DATABASE_SERVER_KEY_INI_PCPKG}\",\"k2hr3-init-systemd-packages\":\"${DATABASE_SERVER_KEY_INI_SYSPKG}\"}"

	#
	# Run k2hr3 for server resource
	#
	if ! K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
		"${K2HR3CLIBIN}" resource create "${K2HR3CLI_DBAAS_CLUSTER_NAME}/server" --keys "${_DATABASE_RESOURCE_SERVER_KEYS}" > /dev/null; then

		prn_msg "${CRED}Failed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}/server\" Resource"
		exit 1
	fi
	prn_msg "${CGRN}Succeed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}/server\" Resource"

	#
	# Make Keys Paramter for slave
	#
	_DATABASE_RESOURCE_SLAVE_KEYS="{\"chmpx-mode\":\"SLAVE\",\"k2hr3-init-packages\":\"${DATABASE_SLAVE_KEY_INI_PKG}\",\"k2hr3-init-packagecloud-packages\":\"${DATABASE_SLAVE_KEY_INI_PCPKG}\",\"k2hr3-init-systemd-packages\":\"${DATABASE_SLAVE_KEY_INI_SYSPKG}\"}"

	#
	# Run k2hr3 for server resource
	#
	if ! K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
		"${K2HR3CLIBIN}" resource create "${K2HR3CLI_DBAAS_CLUSTER_NAME}/slave" --keys "${_DATABASE_RESOURCE_SLAVE_KEYS}" > /dev/null; then

		prn_msg "${CRED}Failed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}/slave\" Resource"
		exit 1
	fi
	prn_msg "${CGRN}Succeed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}/slave\" Resource"

	#------------------------------------------------------
	# Create Main Policy
	#------------------------------------------------------
	#
	# Make Resources Paramter
	#
	_DATABASE_POLICY_RESOURCES="[\"yrn:yahoo:::${_DATABASE_TENANT_NAME}:resource:${K2HR3CLI_DBAAS_CLUSTER_NAME}/server\",\"yrn:yahoo:::${_DATABASE_TENANT_NAME}:resource:${K2HR3CLI_DBAAS_CLUSTER_NAME}/slave\"]"

	#
	# Run k2hr3
	#
	if ! K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
		"${K2HR3CLIBIN}" policy create "${K2HR3CLI_DBAAS_CLUSTER_NAME}" --effect 'allow' --action 'yrn:yahoo::::action:read' --resource "${_DATABASE_POLICY_RESOURCES}" >/dev/null; then

		prn_msg "${CRED}Failed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}\" Policy"
		exit 1
	fi
	prn_msg "${CGRN}Succeed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}\" Policy"

	#------------------------------------------------------
	# Create Main Role
	#------------------------------------------------------
	#
	# Make Policies Paramter
	#
	_DATABASE_ROLE_POLICIES="yrn:yahoo:::${_DATABASE_TENANT_NAME}:policy:${K2HR3CLI_DBAAS_CLUSTER_NAME}"

	#
	# Run k2hr3
	#
	if ! K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
		"${K2HR3CLIBIN}" role create "${K2HR3CLI_DBAAS_CLUSTER_NAME}" --policies "${_DATABASE_ROLE_POLICIES}" >/dev/null; then

		prn_msg "${CRED}Failed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}\" Role"
		exit 1
	fi
	prn_msg "${CGRN}Succeed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}\" Role"

	#------------------------------------------------------
	# Create Server/Slave Role
	#------------------------------------------------------
	#
	# Run k2hr3 for server
	#
	if ! K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
		"${K2HR3CLIBIN}" role create "${K2HR3CLI_DBAAS_CLUSTER_NAME}/server" >/dev/null; then

		prn_msg "${CRED}Failed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}/server\" Role"
		exit 1
	fi
	prn_msg "${CGRN}Succeed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}/server\" Role"

	#
	# Run k2hr3 for slave
	#
	if ! K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
		"${K2HR3CLIBIN}" role create "${K2HR3CLI_DBAAS_CLUSTER_NAME}/slave" >/dev/null; then

		prn_msg "${CRED}Failed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}/slave\" Role"
		exit 1
	fi
	prn_msg "${CGRN}Succeed${CDEF} : Phase : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}/slave\" Role"

	#------------------------------------------------------
	# Create Security Group on OpenStack
	#------------------------------------------------------
	#
	# Create security group
	#
	if [ "${K2HR3CLI_OPENSTACK_NO_SECGRP}" -ne 1 ]; then
		if ! check_op_security_group "${K2HR3CLI_DBAAS_CLUSTER_NAME}"; then
			#
			# Security group for server
			#
			if ! create_op_security_group "${K2HR3CLI_DBAAS_CLUSTER_NAME}" 0; then
				prn_msg "${CRED}Failed${CDEF} : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}\"cluster : Could not create security group for server."
				exit 1
			fi

			#
			# Security group for slave
			#
			if ! create_op_security_group "${K2HR3CLI_DBAAS_CLUSTER_NAME}" 1; then
				prn_msg "${CRED}Failed${CDEF} : Create \"${K2HR3CLI_DBAAS_CLUSTER_NAME}\"cluster : Could not create security group for slave."
				exit 1
			fi
		fi
	fi

	#
	# Finished
	#
	prn_msg "${CGRN}Succeed${CDEF} : Registration of cluster \"${K2HR3CLI_DBAAS_CLUSTER_NAME}\" with K2HR3 is complete"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_SHOW}" ]; then
	#
	# DATABASE SHOW
	#

	#
	# Get Scoped Token
	#
	if ! complement_scoped_token; then
		exit 1
	fi
	prn_dbg "${K2HR3CLI_SCOPED_TOKEN}"

	if [ -z "${K2HR3CLI_DBAAS_SHOW_TYPE}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the type(${_DATABASE_COMMAND_TYPE_HOST} or ${_DATABASE_COMMAND_TYPE_CONF_LONG}(${_DATABASE_COMMAND_TYPE_CONF})), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_DBAAS_SHOW_TYPE}" = "${_DATABASE_COMMAND_TYPE_HOST}" ]; then
		#
		# DATABASE SHOW HOST
		#
		if [ -z "${K2HR3CLI_DBAAS_SHOW_TARGET}" ] || { [ "${K2HR3CLI_DBAAS_SHOW_TARGET}" != "${_DATABASE_COMMAND_TARGET_SERVER}" ] && [ "${K2HR3CLI_DBAAS_SHOW_TARGET}" != "${_DATABASE_COMMAND_TARGET_SLAVE}" ]; }; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND} ${K2HR3CLI_DBAAS_SHOW_TYPE}\" must also specify the (${_DATABASE_COMMAND_TARGET_SERVER} or ${_DATABASE_COMMAND_TARGET_SLAVE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi

		#
		# Run k2hr3 for host in role
		#
		_DATABSE_SHOW_BACKUP_OPT_JSON=${K2HR3CLI_OPT_JSON}
		K2HR3CLI_OPT_JSON=0

		if ! _DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_OPT_JSON="${K2HR3CLI_OPT_JSON}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
			"${K2HR3CLIBIN}" role show "${K2HR3CLI_DBAAS_CLUSTER_NAME}/${K2HR3CLI_DBAAS_SHOW_TARGET}"); then

			#
			# Check Result(failure)
			#
			if [ -z "${_DATABASE_RESULT}" ]; then
				prn_msg "${CRED}Failed${CDEF} : Show ${K2HR3CLI_DBAAS_SHOW_TARGET} host for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster : Failed Sub Process"
			else
				prn_msg "${CRED}Failed${CDEF} : Show ${K2HR3CLI_DBAAS_SHOW_TARGET} host for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster : Sub Process Result(${_DATABASE_RESULT})"
			fi
			exit 1
		fi
		K2HR3CLI_OPT_JSON=${_DATABSE_SHOW_BACKUP_OPT_JSON}

		#
		# Parse Result
		#
		if ! jsonparser_parse_json_string "${_DATABASE_RESULT}"; then
			prn_msg "${CRED}Failed${CDEF} : Show ${K2HR3CLI_DBAAS_SHOW_TARGET} host for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster : Failed to parse result"
			exit 1
		fi

		#
		# Parse Result
		#
		if ! dbaas_show_all_hosts "${JP_PAERSED_FILE}"; then
			prn_msg "${CRED}Failed${CDEF} : Show ${K2HR3CLI_DBAAS_SHOW_TARGET} host for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster"
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

		#
		# Print result
		#
		jsonparser_dump_string "${DATABSE_HOST_LIST}"
		if [ -z "${K2HR3CLI_OPT_JSON}" ] || [ "${K2HR3CLI_OPT_JSON}" != "1" ]; then
			pecho ""
		fi

	elif [ "${K2HR3CLI_DBAAS_SHOW_TYPE}" = "${_DATABASE_COMMAND_TYPE_CONF}" ] || [ "${K2HR3CLI_DBAAS_SHOW_TYPE}" = "${_DATABASE_COMMAND_TYPE_CONF_LONG}" ]; then
		#
		# DATABASE SHOW CONFIGURATION
		#
		if [ -z "${K2HR3CLI_DBAAS_SHOW_TARGET}" ] || { [ "${K2HR3CLI_DBAAS_SHOW_TARGET}" != "${_DATABASE_COMMAND_TARGET_SERVER}" ] && [ "${K2HR3CLI_DBAAS_SHOW_TARGET}" != "${_DATABASE_COMMAND_TARGET_SLAVE}" ]; }; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND} ${K2HR3CLI_DBAAS_SHOW_TYPE}\" must also specify the (${_DATABASE_COMMAND_TARGET_SERVER} or ${_DATABASE_COMMAND_TARGET_SLAVE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi

		#
		# Run k2hr3 for server resource
		#
		if ! _DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_OPT_JSON="${K2HR3CLI_OPT_JSON}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
			"${K2HR3CLIBIN}" resource show "${K2HR3CLI_DBAAS_CLUSTER_NAME}/${K2HR3CLI_DBAAS_SHOW_TARGET}" --expand); then

			#
			# Check Result(failure)
			#
			if [ -z "${_DATABASE_RESULT}" ]; then
				prn_msg "${CRED}Failed${CDEF} : Show ${K2HR3CLI_DBAAS_SHOW_TARGET} configuration for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster : Failed Sub Process"
			else
				prn_msg "${CRED}Failed${CDEF} : Show ${K2HR3CLI_DBAAS_SHOW_TARGET} configuration for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster : Sub Process Result(${_DATABASE_RESULT})"
			fi
			exit 1
		fi

		#
		# Display Result
		#
		pecho "${_DATABASE_RESULT}"

	else
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the type(${_DATABASE_COMMAND_TYPE_HOST} or ${_DATABASE_COMMAND_TYPE_CONF_LONG}(${_DATABASE_COMMAND_TYPE_CONF})), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_ADD}" ]; then
	#
	# DATABASE ADD
	#
	if [ -z "${K2HR3CLI_DBAAS_ADD_TYPE}" ] || [ "${K2HR3CLI_DBAAS_ADD_TYPE}" != "${_DATABASE_COMMAND_TYPE_HOST}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the (${_DATABASE_COMMAND_TYPE_HOST}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	if [ -z "${K2HR3CLI_DBAAS_ADD_TARGET}" ] || { [ "${K2HR3CLI_DBAAS_ADD_TARGET}" != "${_DATABASE_COMMAND_TARGET_SERVER}" ] && [ "${K2HR3CLI_DBAAS_ADD_TARGET}" != "${_DATABASE_COMMAND_TARGET_SLAVE}" ]; }; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the (${_DATABASE_COMMAND_TARGET_SERVER} or ${_DATABASE_COMMAND_TARGET_SLAVE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	if [ -z "${K2HR3CLI_DBAAS_HOST_NAME}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must specify the host name, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

	#
	# Get Scoped Token
	#
	if ! complement_scoped_token; then
		exit 1
	fi
	prn_dbg "${K2HR3CLI_SCOPED_TOKEN}"

	#
	# Get OpenStack Scoped Token
	#
	if ! complement_op_token; then
		prn_err "Failed to get OpenStack Scoped Token"
		exit 1
	fi

	#
	# Role name
	#
	_DATABASE_ADD_HOST_CLUSTER=${K2HR3CLI_DBAAS_CLUSTER_NAME}/${K2HR3CLI_DBAAS_ADD_TARGET}

	#
	# Check Existed Role Token
	#
	_DATABASE_ADD_HOST_ROLETOKEN=""
	_DATABASE_ADD_HOST_REGISTERPATH=""
	if [ -z "${K2HR3CLI_OPT_DBAAS_CREATE_ROLETOKEN}" ] || [ "${K2HR3CLI_OPT_DBAAS_CREATE_ROLETOKEN}" != "1" ]; then
		if dbaas_get_existed_role_token "${_DATABASE_ADD_HOST_CLUSTER}"; then
			_DATABASE_ADD_HOST_ROLETOKEN=${DBAAS_FOUND_ROLETOKEN}
			_DATABASE_ADD_HOST_REGISTERPATH=${DBAAS_FOUND_REGISTERPATH}
		fi
	fi

	#
	# Create New Role Token
	#
	if [ -z "${_DATABASE_ADD_HOST_ROLETOKEN}" ]; then
		if dbaas_create_role_token "${_DATABASE_ADD_HOST_CLUSTER}"; then
			_DATABASE_ADD_HOST_ROLETOKEN=${DBAAS_NEW_ROLETOKEN}
			_DATABASE_ADD_HOST_REGISTERPATH=${DBAAS_NEW_REGISTERPATH}
		fi
	fi

	#
	# Check Role Token
	#
	if [ -z "${_DATABASE_ADD_HOST_ROLETOKEN}" ] || [ -z "${_DATABASE_ADD_HOST_REGISTERPATH}" ]; then
		prn_msg "${CRED}Failed${CDEF} : Add ${K2HR3CLI_DBAAS_ADD_TARGET} host for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster : Could not create(find) Role Token."
		exit 1
	fi

	#
	# Set User Data Script
	#
	# [MEMO]
	#	#include
	#	${K2HR3CLI_API_URI}/v1/userdata/${_DATABASE_ADD_HOST_REGISTERPATH}
	#
	_DATABASE_ADD_HOST_USD="#include\n${K2HR3CLI_API_URI}/v1/userdata/${_DATABASE_ADD_HOST_REGISTERPATH}"
	_DATABASE_ADD_HOST_USD64=$(pecho -n "${_DATABASE_ADD_HOST_USD}" | sed 's/\\n/\n/g' | base64 | tr -d '\n')

	#
	# Check security group
	#
	_DATABASE_ADD_HOST_SECGRP=""
	if check_op_security_group "${K2HR3CLI_DBAAS_CLUSTER_NAME}"; then
		if [ -n "${K2HR3CLI_DBAAS_ADD_TARGET}" ] && [ "${K2HR3CLI_DBAAS_ADD_TARGET}" = "${_DATABASE_COMMAND_TARGET_SERVER}" ]; then
			_DATABASE_ADD_HOST_SECGRP=$(get_op_security_group_name "${K2HR3CLI_DBAAS_CLUSTER_NAME}" 0)
		else
			_DATABASE_ADD_HOST_SECGRP=$(get_op_security_group_name "${K2HR3CLI_DBAAS_CLUSTER_NAME}" 1)
		fi
	fi

	#
	# Check Keypair
	#
	if [ -n "${K2HR3CLI_OPENSTACK_KEYPAIR}" ]; then
		if ! check_op_keypair "${K2HR3CLI_OPENSTACK_KEYPAIR}"; then
			prn_msg "${CRED}Failed${CDEF} : Add ${K2HR3CLI_DBAAS_ADD_TARGET} host for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster : Could not find keypair(${K2HR3CLI_OPENSTACK_KEYPAIR})."
			exit 1
		fi
	fi

	#
	# Check image
	#
	if [ -z "${K2HR3CLI_OPENSTACK_IMAGE_ID}" ]; then
		if ! check_op_image "${K2HR3CLI_OPENSTACK_IMAGE}"; then
			prn_msg "${CRED}Failed${CDEF} : Add ${K2HR3CLI_DBAAS_ADD_TARGET} host for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster : The OS image name is not specified or wrong image name(${K2HR3CLI_COMMAND_OPT_OPENSTACK_IMAGE_LONG} option)."
			exit 1
		fi
	fi

	#
	# Check flavor
	#
	if [ -z "${K2HR3CLI_OPENSTACK_FLAVOR_ID}" ]; then
		if ! check_op_flavor "${K2HR3CLI_OPENSTACK_FLAVOR}"; then
			prn_msg "${CRED}Failed${CDEF} : Add ${K2HR3CLI_DBAAS_ADD_TARGET} host for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster : The flavor name is not specified or flavor name(${K2HR3CLI_COMMAND_OPT_OPENSTACK_FLAVOR_LONG} option)."
			exit 1
		fi
	fi

	#
	# Make create host post data
	#
	_DATABASE_ADD_HOST_POST_DATA=$(dbaas_get_openstack_launch_post_data \
										"${K2HR3CLI_DBAAS_HOST_NAME}" \
										"${K2HR3CLI_OPENSTACK_IMAGE_ID}" \
										"${K2HR3CLI_OPENSTACK_FLAVOR_ID}" \
										"${_DATABASE_ADD_HOST_USD64}" \
										"${K2HR3CLI_OPENSTACK_KEYPAIR}" \
										"${_DATABASE_ADD_HOST_SECGRP}" \
										"${K2HR3CLI_OPENSTACK_BCLOKDEVICE}")

	#
	# Create Virtual Machine
	#
	if ! create_op_host "${_DATABASE_ADD_HOST_POST_DATA}"; then
		prn_msg "${CRED}Failed${CDEF} : Add ${K2HR3CLI_DBAAS_ADD_TARGET} host(${K2HR3CLI_DBAAS_HOST_NAME}) for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster."
		exit 1
	fi

	prn_msg "${CGRN}Succeed${CDEF} : Add ${K2HR3CLI_DBAAS_ADD_TARGET} host(${K2HR3CLI_DBAAS_HOST_NAME} - \"${K2HR3CLI_OPENSTACK_CREATED_SERVER_ID}\") for ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster."

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_DELETE}" ]; then
	#
	# DATABASE DELETE
	#

	#
	# Get Scoped Token
	#
	if ! complement_scoped_token; then
		exit 1
	fi
	prn_dbg "${K2HR3CLI_SCOPED_TOKEN}"

	#
	# Get OpenStack Scoped Token
	#
	if ! complement_op_token; then
		prn_err "Failed to get OpenStack Scoped Token"
		exit 1
	fi

	if [ -z "${K2HR3CLI_DBAAS_DELETE_TYPE}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the (${_DATABASE_COMMAND_TYPE_HOST} or ${_DATABASE_COMMAND_TYPE_CLUSTER}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_DBAAS_DELETE_TYPE}" = "${_DATABASE_COMMAND_TYPE_HOST}" ]; then
		#
		# HOST DELETE
		#
		if [ -z "${K2HR3CLI_DBAAS_HOST_NAME}" ]; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND} ${K2HR3CLI_DBAAS_DELETE_TYPE}\" must also specify the hostname, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi

		#
		# Search host in roles
		#
		_DBAAS_FIND_HOST_ROLE=""
		if ! dbaas_find_role_host "${K2HR3CLI_DBAAS_CLUSTER_NAME}/${_DATABASE_COMMAND_TARGET_SERVER}" "${K2HR3CLI_DBAAS_HOST_NAME}"; then
			if ! dbaas_find_role_host "${K2HR3CLI_DBAAS_CLUSTER_NAME}/${_DATABASE_COMMAND_TARGET_SLAVE}" "${K2HR3CLI_DBAAS_HOST_NAME}"; then
				prn_msg "${CRED}Failed${CDEF} : Not found ${K2HR3CLI_DBAAS_HOST_NAME} in ${K2HR3CLI_DBAAS_CLUSTER_NAME} role."
				exit 1
			else
				_DBAAS_FIND_HOST_ROLE="${K2HR3CLI_DBAAS_CLUSTER_NAME}/${_DATABASE_COMMAND_TARGET_SLAVE}"
			fi
		else
			_DBAAS_FIND_HOST_ROLE="${K2HR3CLI_DBAAS_CLUSTER_NAME}/${_DATABASE_COMMAND_TARGET_SERVER}"
		fi

		#
		# Delete host in OpenStack
		#
		if [ -n "${DBAAS_FIND_ROLE_HOST_CUK}" ]; then
			if ! delete_op_host "${DBAAS_FIND_ROLE_HOST_CUK}"; then
				prn_msg "${CRED}Failed${CDEF} : Delete ${K2HR3CLI_DBAAS_HOST_NAME} from OpenStack."
				exit 1
			fi
		else
			prn_warn "Found ${K2HR3CLI_DBAAS_HOST_NAME} host in ${K2HR3CLI_DBAAS_CLUSTER_NAME} role, but it does not have Host id for opensteck. Then could not delete it from OpenStack."
		fi

		#
		# Delete host from role
		#
		if ! dbaas_delete_role_host "${_DBAAS_FIND_HOST_ROLE}" "${DBAAS_FIND_ROLE_HOST_NAME}" "${DBAAS_FIND_ROLE_HOST_PORT}" "${DBAAS_FIND_ROLE_HOST_CUK}"; then
			prn_msg "${CRED}Failed${CDEF} : Delete ${K2HR3CLI_DBAAS_HOST_NAME} from ${K2HR3CLI_DBAAS_CLUSTER_NAME} role"
			exit 1
		fi

		prn_msg "${CGRN}Succeed${CDEF} : Delete host ${K2HR3CLI_DBAAS_HOST_NAME} from ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster(OpenStack and K2HR3)."

	elif [ "${K2HR3CLI_DBAAS_DELETE_TYPE}" = "${_DATABASE_COMMAND_TYPE_CLUSTER}" ]; then
		#
		# CLUSTER DELETE
		#

		#
		# Special Message and need confirm
		#
		if [ -z "${K2HR3CLI_OPENSTACK_CONFIRM_YES}" ] || [ "${K2HR3CLI_OPENSTACK_CONFIRM_YES}" != "1" ]; then
			_OLD_K2HR3CLI_OPT_INTERACTIVE=${K2HR3CLI_OPT_INTERACTIVE}
			K2HR3CLI_OPT_INTERACTIVE=1

			completion_variable_auto "_DBAAS_DELETE_CONFIRM" "${CRED}[IMPORTANT CONFIRM]${CDEF} You will lose all data/server in your cluster, Do you still want to run it? (y/n) " 0
			if [ -z "${_DBAAS_DELETE_CONFIRM}" ] || { [ "${_DBAAS_DELETE_CONFIRM}" != "y" ] && [ "${_DBAAS_DELETE_CONFIRM}" != "yes" ] && [ "${_DBAAS_DELETE_CONFIRM}" != "Y" ] && [ "${_DBAAS_DELETE_CONFIRM}" != "YES" ]; }; then
				exit 0
			fi
			K2HR3CLI_OPT_INTERACTIVE=${_OLD_K2HR3CLI_OPT_INTERACTIVE}
		fi
		prn_msg "${CRED}[NOTICE] Delete all of the cluster configuration, data, cluster hosts, and so on.${CDEF}"

		#
		# Delete all host from OpenStack and K2HR3
		#
		if ! dbaas_delete_role_host_all "${K2HR3CLI_DBAAS_CLUSTER_NAME}"; then
			prn_msg "${CRED}Failed${CDEF} : Delete ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster, because could not delele a host."
			exit 1
		fi

		#
		# Delete Security Group
		#
		if ! delete_op_security_groups "${K2HR3CLI_DBAAS_CLUSTER_NAME}"; then
			prn_msg "${CRED}Failed${CDEF} : Delete ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster, because could not delele security groups."
			exit 1
		fi

		#
		# Delete all in K2HR3
		#
		if ! dbaas_delete_all_k2hr3 "${K2HR3CLI_DBAAS_CLUSTER_NAME}"; then
			prn_msg "${CRED}Failed${CDEF} : Delete ${K2HR3CLI_DBAAS_CLUSTER_NAME} in K2HR3."
			exit 1
		fi

		prn_msg "${CGRN}Succeed${CDEF} : Delete all ${K2HR3CLI_DBAAS_CLUSTER_NAME} cluster(OpenStack and K2HR3)."

	else
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the (${_DATABASE_COMMAND_TYPE_HOST} or ${_DATABASE_COMMAND_TYPE_CLUSTER}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_OPENSTACK}" ]; then
	#
	# OPENSTACK TOKEN
	#
	if [ -z "${K2HR3CLI_DBAAS_OPENSTACK_TYPE}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the token type(${_DATABASE_COMMAND_TYPE_OPUTOKEN} or ${_DATABASE_COMMAND_TYPE_OPTOKEN}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_DBAAS_OPENSTACK_TYPE}" = "${_DATABASE_COMMAND_TYPE_OPUTOKEN}" ]; then
		#
		# CREATE UNSCOPED TOKEN
		#

		#
		# Clear current openstack token
		#
		K2HR3CLI_OPENSTACK_TOKEN=

		#
		# Create new token
		#
		if ! complement_op_utoken; then
			prn_err "Failed to create OpenStack Unscoped Token"
			exit 1
		fi

		#
		# Save
		#
		if [ -n "${K2HR3CLI_OPT_SAVE}" ] && [ "${K2HR3CLI_OPT_SAVE}" = "1" ]; then
			if ! config_default_set_key "K2HR3CLI_OPENSTACK_TOKEN" "${K2HR3CLI_OPENSTACK_TOKEN}"; then
				prn_err "Created OpenStack Unscoped Token, but failed to save it to configuration."
				exit 1
			fi
		fi
		prn_msg "${K2HR3CLI_OPENSTACK_TOKEN}"

	elif [ "${K2HR3CLI_DBAAS_OPENSTACK_TYPE}" = "${_DATABASE_COMMAND_TYPE_OPTOKEN}" ]; then
		#
		# CREATE SCOPED TOKEN
		#

		#
		# Create new token
		#
		if ! complement_op_token; then
			prn_err "Failed to create OpenStack Scoped Token"
			exit 1
		fi

		#
		# Save
		#
		if [ -n "${K2HR3CLI_OPT_SAVE}" ] && [ "${K2HR3CLI_OPT_SAVE}" = "1" ]; then
			if ! config_default_set_key "K2HR3CLI_OPENSTACK_TOKEN" "${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"; then
				prn_err "Created OpenStack Scoped Token, but failed to save it to configuration."
				exit 1
			fi
		fi
		prn_msg "${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"

	else
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the token type(${_DATABASE_COMMAND_TYPE_OPUTOKEN} or ${_DATABASE_COMMAND_TYPE_OPTOKEN}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_DATABASE_COMMAND_SUB_LIST}" ]; then
	#
	# LIST IMAGES/FLAVORS
	#

	#
	# Get OpenStack Scoped Token
	#
	if ! complement_op_token; then
		prn_err "Failed to get OpenStack Scoped Token"
		exit 1
	fi

	if [ -z "${K2HR3CLI_DBAAS_LIST_TYPE}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the list type(${_DATABASE_COMMAND_TYPE_IMAGES} or ${_DATABASE_COMMAND_TYPE_FLAVORS}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_DBAAS_LIST_TYPE}" = "${_DATABASE_COMMAND_TYPE_IMAGES}" ]; then
		#
		# List images
		#
		if ! display_op_image_list; then
			prn_msg "${CRED}Failed${CDEF} : List OpenStack Images."
			return 1
		fi

	elif [ "${K2HR3CLI_DBAAS_LIST_TYPE}" = "${_DATABASE_COMMAND_TYPE_FLAVORS}" ]; then
		#
		# List flavors
		#

		#
		# Get tenant id
		#
		if ! complement_op_tenant; then
			prn_err "Failed to get OpenStack Tenant"
			return 1
		fi

		if ! display_op_flavor_list; then
			prn_msg "${CRED}Failed${CDEF} : List OpenStack Flavors."
			return 1
		fi
	else
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the list type(${_DATABASE_COMMAND_TYPE_IMAGES} or ${_DATABASE_COMMAND_TYPE_FLAVORS}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

else
	prn_err "Unknown subcommand(\"${K2HR3CLI_SUBCOMMAND}\") is specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
fi

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
