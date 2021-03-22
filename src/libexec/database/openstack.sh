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

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
#TEST
#	#
#	# Endpoints for openstack services
#	#
#	# These values are set when the Token is verified or the Scoped Token is issued.
#	#
#	K2HR3CLI_OPENSTACK_NOVA_URI=""
#	K2HR3CLI_OPENSTACK_GLANCE_URI=""
#	K2HR3CLI_OPENSTACK_NEUTRON_URI=""

#
# Security Group Name
#
K2HR3CLI_OPENSTACK_SERVER_SECGRP_SUFFIX="-k2hdkc-server-sec"
K2HR3CLI_OPENSTACK_SLAVE_SECGRP_SUFFIX="-k2hdkc-slave-sec"

#--------------------------------------------------------------
# Functions for OpenStack 
#--------------------------------------------------------------
#
# Complement and Set OpenStack user name
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_OPENSTACK_USER
#	K2HR3CLI_OPENSTACK_USER_ID
#	K2HR3CLI_OPENSTACK_PASS
#	K2HR3CLI_OPENSTACK_TOKEN
#	K2HR3CLI_OPENSTACK_SCOPED_TOKEN
#	K2HR3CLI_USER
#
complement_op_user_name()
{
	#
	# Check alternative values
	#
	if [ "X${K2HR3CLI_OPENSTACK_USER}" = "X" ]; then
		#
		# Reset user id / passphrase / tokens
		#
		K2HR3CLI_OPENSTACK_USER_ID=""
		K2HR3CLI_OPENSTACK_PASS=""
		K2HR3CLI_OPENSTACK_TOKEN=""
		K2HR3CLI_OPENSTACK_SCOPED_TOKEN=""

		if [ "X${K2HR3CLI_USER}" != "X" ]; then
			K2HR3CLI_OPENSTACK_USER=${K2HR3CLI_USER}
		fi
	fi

	#
	# Interacvive input
	#
	completion_variable_auto "K2HR3CLI_OPENSTACK_USER" "OpenStack User name: " 1
	_TOKEN_LIB_RESULT_TMP=$?
	prn_dbg "(complement_op_user_name) OpenStack User name = \"${K2HR3CLI_OPENSTACK_USER}\"."
	return ${_TOKEN_LIB_RESULT_TMP}
}

#
# Complement and Set OpenStack user passphrase
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_OPENSTACK_PASS
#	K2HR3CLI_PASS
#
complement_op_user_passphrase()
{
	#
	# Check alternative values
	#
	if [ "X${K2HR3CLI_OPENSTACK_PASS}" = "X" ]; then
		#
		# Reset tokens
		#
		K2HR3CLI_OPENSTACK_TOKEN=""
		K2HR3CLI_OPENSTACK_SCOPED_TOKEN=""

		if [ "X${K2HR3CLI_PASS}" != "X" ]; then
			K2HR3CLI_OPENSTACK_PASS=${K2HR3CLI_PASS}
		fi
	fi

	#
	# Interacvive input
	#
	completion_variable_auto "K2HR3CLI_OPENSTACK_PASS" "OpenStack User passphrase: " 1 1
	_TOKEN_LIB_RESULT_TMP=$?
	prn_dbg "(complement_op_user_passphrase) OpenStack User passphrase = \"*****(${#K2HR3CLI_OPENSTACK_PASS})\"."
	return ${_TOKEN_LIB_RESULT_TMP}
}

#
# Complement and Set OpenStack Tenant
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_OPENSTACK_TENANT
#	K2HR3CLI_OPENSTACK_TENANT_ID
#	K2HR3CLI_TENANT
#
complement_op_tenant()
{
	#
	# Check alternative values
	#
	if [ "X${K2HR3CLI_OPENSTACK_TENANT}" = "X" ]; then
		#
		# Reset tenant id / tokens
		#
		K2HR3CLI_OPENSTACK_TENANT_ID=""
		K2HR3CLI_OPENSTACK_TOKEN=""
		K2HR3CLI_OPENSTACK_SCOPED_TOKEN=""

		if [ "X${K2HR3CLI_TENANT}" != "X" ]; then
			K2HR3CLI_OPENSTACK_TENANT=${K2HR3CLI_TENANT}
		fi
	fi
	#
	# Interacvive input
	#
	completion_variable_auto "K2HR3CLI_OPENSTACK_TENANT" "OpenStack Project(tenant) name: " 1
	_TOKEN_LIB_RESULT_TMP=$?
	prn_dbg "(complement_op_tenant) OpenStack Project(tenant) name = \"${K2HR3CLI_OPENSTACK_TENANT}\"."
	return ${_TOKEN_LIB_RESULT_TMP}
}

#
# Complement and Set OpenStack unscoped token
#
# $?	: result
#
# Set Variables
#	K2HR3CLI_OPENSTACK_USER			: user name
#	K2HR3CLI_OPENSTACK_USER_ID		: user id
#	K2HR3CLI_OPENSTACK_TOKEN		: valid token (unscoped token)
#	K2HR3CLI_OPENSTACK_SCOPED_TOKEN
#
complement_op_utoken()
{
	#
	# Reset Tokens
	#
	K2HR3CLI_OPENSTACK_TOKEN=""
	K2HR3CLI_OPENSTACK_SCOPED_TOKEN=""

	#
	# Get unscoped token
	#
	complement_op_user_name
	if [ $? -ne 0 ]; then
		return 1
	fi
	complement_op_user_passphrase
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Create Unscoped Token
	#
	get_op_utoken "${K2HR3CLI_OPENSTACK_USER}" "${K2HR3CLI_OPENSTACK_PASS}"
	if [ $? -ne 0 ]; then
		return 1
	fi
	return 0
}

#
# Complement and Set OpenStack Scoped token
#
# $?	: result
#
# Using and Set Variables
#	K2HR3CLI_OPENSTACK_TOKEN		: valid token (may be scoped token)
#	K2HR3CLI_OPENSTACK_SCOPED_TOKEN	: valid scoped token
#	K2HR3CLI_OPENSTACK_USER			: user name
#	K2HR3CLI_OPENSTACK_USER_ID		: user id
#	K2HR3CLI_OPENSTACK_PASS			: user name
#	K2HR3CLI_OPENSTACK_TENANT		: tenant(scoped token)
#	K2HR3CLI_OPENSTACK_TENANT_ID	: tenant id
#	K2HR3CLI_OPENSTACK_NOVA_URI		: endpoint uri for nova
#	K2HR3CLI_OPENSTACK_GLANCE_URI	: endpoint uri for glance
#	K2HR3CLI_OPENSTACK_NEUTRON_URI	: endpoint uri for neutron
#
complement_op_token()
{
	#
	# Reset Tokens
	#
	K2HR3CLI_OPENSTACK_SCOPED_TOKEN=""

	#
	# Check existed openstack token
	#
	if [ "X${K2HR3CLI_OPENSTACK_TOKEN}" != "X" ]; then
		get_op_token_info "${K2HR3CLI_OPENSTACK_TOKEN}"
		if [ $? -eq 0 ]; then
			if [ "X${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}" != "X" ]; then
				#
				# Valid token which is scoped token, so nothing to do
				#
				return 0
			fi
		else
			K2HR3CLI_OPENSTACK_TOKEN=""
		fi
	fi

	#
	# Get unscoped token
	#
	if [ "X${K2HR3CLI_OPENSTACK_TOKEN}" = "X" ]; then
		#
		# No unscoped token, then create it
		#
		complement_op_user_name
		if [ $? -ne 0 ]; then
			return 1
		fi
		complement_op_user_passphrase
		if [ $? -ne 0 ]; then
			return 1
		fi

		#
		# Create Unscoped Token
		#
		get_op_utoken "${K2HR3CLI_OPENSTACK_USER}" "${K2HR3CLI_OPENSTACK_PASS}"
		if [ $? -ne 0 ]; then
			return 1
		fi
	fi

	#
	# Get tenant id
	#
	complement_op_tenant
	if [ $? -ne 0 ]; then
		return 1
	fi
	get_op_tenant_id
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Get Scoped Token
	#
	get_op_token
	if [ $? -ne 0 ]; then
		return 1
	fi

	return 0
}

#--------------------------------------------------------------
# Functions for API Requests
#--------------------------------------------------------------
#
# Get Service endpoint in catalog
#
# $1	: type(string)
# $2	: name(string)
# $3	: parsed json file(catalog response)
# $?	: result
#
# [NOTE] catalog response
#	{
#		"catalog": [
#			{
#				"endpoints": [
#					{
#						"id": "...",
#						"interface": "public",
#						"region": "RegionOne",
#						"url": "http://..."
#					},
#					{
#						"id": "...",
#						"interface": "internal",
#						"region": "RegionOne",
#						"url": "http://..."
#					},
#	                ...
#				],
#				"id": "...",
#				"type": "identity",
#				"name": "keystone"
#			},
#			...
#		],
#		"links": {
#			"self": "https://.../identity/v3/catalog",
#			"previous": null,
#			"next": null
#		}
#	}
#
# Set Variables
#	DBAAS_OP_FOUND_SERVICE_EP_URI	: endpoint(ex. https://XXX.XXX.XXX.XXX/...)
#
get_op_service_ep()
{
	DBAAS_OP_FOUND_SERVICE_EP_URI=""

	if [ "X$1" = "X" ] || [ "X$2" = "X" ] || [ "X$3" = "X" ]; then
		return 1
	fi
	_DBAAS_OP_SERVICE_TYPE=$1
	_DBAAS_OP_SERVICE_NAME=$2
	_DBAAS_OP_PARSED_FILE=$3

	#
	# Get catalog array
	#
	jsonparser_get_key_value '%"catalog"%' "$3"
	if [ $? -ne 0 ]; then
		prn_dbg "(get_op_service_ep) Failed to parse for \"catalog\"."
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_ARR}" ]; then
		prn_dbg "(get_op_service_ep) \"catalog\" is not array."
		return 1
	fi
	_DATABASE_RESULT_CATALOG_LIST=${JSONPARSER_FIND_KEY_VAL}

	#
	# Loop catalog
	#
	for _DATABASE_RESULT_CATALOG_POS in ${_DATABASE_RESULT_CATALOG_LIST}; do
		#
		# catalog[x]->name
		#
		_DATABASE_RESULT_CATALOG_POS_RAW=$(pecho -n "${_DATABASE_RESULT_CATALOG_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"catalog\"%${_DATABASE_RESULT_CATALOG_POS_RAW}%\"name\"%" "${_DBAAS_OP_PARSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(get_op_service_ep) Failed to get ${_DBAAS_DEL_ROLE_PATH} catalog[${_DATABASE_RESULT_CATALOG_POS_RAW}]->name."
			continue
		fi
		_DBAAS_OP_CATALOG_NAME=${JSONPARSER_FIND_STR_VAL}

		#
		# catalog[x]->type
		#
		jsonparser_get_key_value "%\"catalog\"%${_DATABASE_RESULT_CATALOG_POS_RAW}%\"type\"%" "${_DBAAS_OP_PARSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(get_op_service_ep) Failed to get ${_DBAAS_DEL_ROLE_PATH} catalog[${_DATABASE_RESULT_CATALOG_POS_RAW}]->type."
			continue
		fi
		_DBAAS_OP_CATALOG_TYPE=${JSONPARSER_FIND_STR_VAL}

		#
		# Compare
		#
		if [ "X${_DBAAS_OP_CATALOG_NAME}" = "X${_DBAAS_OP_SERVICE_NAME}" ] && [ "X${_DBAAS_OP_CATALOG_TYPE}" = "X${_DBAAS_OP_SERVICE_TYPE}" ]; then
			#
			# Found, get endpoints for service
			#
			jsonparser_get_key_value "%\"catalog\"%${_DATABASE_RESULT_CATALOG_POS_RAW}%\"endpoints\"%" "${_DBAAS_OP_PARSED_FILE}"
			if [ $? -ne 0 ]; then
				prn_dbg "(get_op_service_ep) Failed to get ${_DBAAS_DEL_ROLE_PATH} catalog[${_DATABASE_RESULT_CATALOG_POS_RAW}]->endpoints."
				continue
			fi
			_DATABASE_RESULT_EP_LIST=${JSONPARSER_FIND_KEY_VAL}

			for _DATABASE_RESULT_EP_POS in ${_DATABASE_RESULT_EP_LIST}; do
				#
				# catalog[x]->endpoints[x]->url
				#
				_DATABASE_RESULT_EP_POS_RAW=$(pecho -n "${_DATABASE_RESULT_EP_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
				jsonparser_get_key_value "%\"catalog\"%${_DATABASE_RESULT_CATALOG_POS_RAW}%\"endpoints\"%${_DATABASE_RESULT_EP_POS_RAW}%\"url\"%" "${_DBAAS_OP_PARSED_FILE}"
				if [ $? -eq 0 ]; then
					#
					# Cut last word if it is '/' and space
					#
					DBAAS_OP_FOUND_SERVICE_EP_URI=$(pecho -n "${JSONPARSER_FIND_STR_VAL}" | sed -e 's/[[:space:]]+//g' -e 's#/$##g')
					return 0
				else
					prn_dbg "(get_op_service_ep) Failed to get ${_DBAAS_DEL_ROLE_PATH} catalog[${_DATABASE_RESULT_CATALOG_POS_RAW}]->endpoints[${_DATABASE_RESULT_EP_POS_RAW}]->url."
				fi
			done
		fi
	done

	#
	# Not found
	#
	return 1
}

#
# Set OpenStack services endpoints
#
# $1	: openstack scoped token
# $?	: result
#
# Check and Set Variables
#	K2HR3CLI_OPENSTACK_NOVA_URI		: endpoint uri for nova
#	K2HR3CLI_OPENSTACK_GLANCE_URI	: endpoint uri for glance
#	K2HR3CLI_OPENSTACK_NEUTRON_URI	: endpoint uri for neutron
#
get_op_service_eps()
{
	if [ "X$1" = "X" ]; then
		return 1
	fi
	if [ "X${K2HR3CLI_OPENSTACK_NOVA_URI}" != "X" ] && [ "X${K2HR3CLI_OPENSTACK_GLANCE_URI}" != "X" ] && [ "X${K2HR3CLI_OPENSTACK_NEUTRON_URI}" != "X" ]; then
		#
		# All endpoints is set, nothing to do
		#
		prn_dbg "(get_op_service_eps) OpenStack Nova Endpoint    = ${K2HR3CLI_OPENSTACK_NOVA_URI}"
		prn_dbg "(get_op_service_eps) OpenStack Glance Endpoint  = ${K2HR3CLI_OPENSTACK_GLANCE_URI}"
		prn_dbg "(get_op_service_eps) OpenStack Neutron Endpoint = ${K2HR3CLI_OPENSTACK_NEUTRON_URI}"
		return 0
	fi

	#------------------------------------------------------
	# Get Endpoints(Catalog)
	#------------------------------------------------------
	# [MEMO]
	#	GET http://<OpenStack Identity URI>/v3/auth/catalog
	# 
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_IDENTITY_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:$1"
	_DBAAS_OP_URL_PATH="/v3/auth/catalog"

	get_request "${_DBAAS_OP_URL_PATH}" 1 "${_DBAAS_OP_AUTH_HEADER}" "${_DBAAS_OP_TOKEN_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200" 1
	if [ $? -ne 0 ]; then
		prn_err "Failed to send the request to get catalog inforamtion."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Get endpoints in catalog
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		"catalog": [
	#			{
	#				"endpoints": [
	#					{
	#						"id": "...",
	#						"interface": "public",
	#						"region": "RegionOne",
	#						"url": "http://..."
	#					},
	#					{
	#						"id": "...",
	#						"interface": "internal",
	#						"region": "RegionOne",
	#						"url": "http://..."
	#					},
	#	                ...
	#				],
	#				"id": "...",
	#				"type": "identity",
	#				"name": "keystone"
	#			},
	#			...
	#		],
	#		"links": {
	#			"self": "https://.../identity/v3/catalog",
	#			"previous": null,
	#			"next": null
	#		}
	#	}
	#
	_DBAAS_OP_SERVICE_EPS_RESULT=0

	#
	# Get Nova Uri
	#
	if [ "X${K2HR3CLI_OPENSTACK_NOVA_URI}" = "X" ]; then
		get_op_service_ep "compute" "nova" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_warn "OpenStack Nova endpoint is not found in catalog information."
			_DBAAS_OP_SERVICE_EPS_RESULT=1
		else
			K2HR3CLI_OPENSTACK_NOVA_URI=${DBAAS_OP_FOUND_SERVICE_EP_URI}
			add_config_update_var "K2HR3CLI_OPENSTACK_NOVA_URI"
			prn_dbg "(get_op_service_eps) OpenStack Nova Endpoint    = ${K2HR3CLI_OPENSTACK_NOVA_URI}"
		fi
	fi

	#
	# Get Glance Uri
	#
	if [ "X${K2HR3CLI_OPENSTACK_GLANCE_URI}" = "X" ]; then
		get_op_service_ep "image" "glance" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_warn "OpenStack Glance endpoint is not found in catalog information."
			_DBAAS_OP_SERVICE_EPS_RESULT=1
		else
			K2HR3CLI_OPENSTACK_GLANCE_URI=${DBAAS_OP_FOUND_SERVICE_EP_URI}
			add_config_update_var "K2HR3CLI_OPENSTACK_GLANCE_URI"
			prn_dbg "(get_op_service_eps) OpenStack Glance Endpoint  = ${K2HR3CLI_OPENSTACK_GLANCE_URI}"
		fi
	fi

	#
	# Get Neutron Uri
	#
	if [ "X${K2HR3CLI_OPENSTACK_NEUTRON_URI}" = "X" ]; then
		get_op_service_ep "network" "neutron" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_warn "OpenStack Neutron endpoint is not found in catalog information."
			_DBAAS_OP_SERVICE_EPS_RESULT=1
		else
			K2HR3CLI_OPENSTACK_NEUTRON_URI=${DBAAS_OP_FOUND_SERVICE_EP_URI}
			add_config_update_var "K2HR3CLI_OPENSTACK_NEUTRON_URI"
			prn_dbg "(get_op_service_eps) OpenStack Neutron Endpoint = ${K2HR3CLI_OPENSTACK_NEUTRON_URI}"
		fi
	fi
	rm -f "${JP_PAERSED_FILE}"

	return "${_DBAAS_OP_SERVICE_EPS_RESULT}"
}

#
# Check OpenStack (Un)scoped Token
#
# $1	: openstack token(unscoped/scoped)
# $?	: result
#
# Set Variables
#	K2HR3CLI_OPENSTACK_TOKEN		: valid token (may be scoped token)
#	K2HR3CLI_OPENSTACK_SCOPED_TOKEN	: valid scoped token
#	K2HR3CLI_OPENSTACK_USER			: user name
#	K2HR3CLI_OPENSTACK_USER_ID		: user id
#	K2HR3CLI_OPENSTACK_TENANT		: tenant(scoped token)
#	K2HR3CLI_OPENSTACK_TENANT_ID	: tenant id
#	K2HR3CLI_OPENSTACK_NOVA_URI		: endpoint uri for nova
#	K2HR3CLI_OPENSTACK_GLANCE_URI	: endpoint uri for glance
#	K2HR3CLI_OPENSTACK_NEUTRON_URI	: endpoint uri for neutron
#
get_op_token_info()
{
	if [ "X${K2HR3CLI_OPENSTACK_IDENTITY_URI}" = "X" ]; then
		prn_err "OpenStack(Identity) URI is not specified. Please specify with the ${K2HR3CLI_COMMAND_OPT_OPENSTACK_IDENTITY_URI_LONG} option, K2HR3CLI_OPENSTACK_IDENTITY_URI environment variable, or configuration."
		return 1
	fi
	if [ "X$1" = "X" ]; then
		return 1
	fi

	#------------------------------------------------------
	# Get token information
	#------------------------------------------------------
	# [MEMO]
	#	GET http://<OpenStack Identity URI>/v3/auth/tokens?nocatalog
	# 
	#	("nocatalog" argument is supported after Havana)
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_IDENTITY_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:$1"
	_DBAAS_OP_TOKEN_HEADER="X-Subject-Token:$1"
	_DBAAS_OP_URL_PATH="/v3/auth/tokens?nocatalog"

	get_request "${_DBAAS_OP_URL_PATH}" 1 "${_DBAAS_OP_AUTH_HEADER}" "${_DBAAS_OP_TOKEN_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
	_DBAAS_OP_TOKEN_PAERSED_FILE=${JP_PAERSED_FILE}

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${_DBAAS_OP_TOKEN_PAERSED_FILE}" "200" 1 2>/dev/null
	if [ $? -ne 0 ]; then
		prn_info "Failed to send the request to get Token inforamtion."
		rm -f "${_DBAAS_OP_TOKEN_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Get user id in result(parse result)
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		...
	#		...
	#		"token": {
	#			"methods": ["password"], 
	#			"user": {
	#				"domain": {
	#					"id": "default", 
	#					"name": "Default"
	#				}, 
	#				"id": "<User ID>", 
	#				"name": "<User Name>", 
	#				"password_expires_at": null
	#			}, 
	#			"audit_ids": ["...."], 
	#			"expires_at": "2021-01-01T00:00:00.000000Z", 
	#			"issued_at": "2021-01-01T00:00:00.000000Z"
	#		}
	#	}
	#
	_DBAAS_OP_USER=
	_DBAAS_OP_USER_ID=

	#
	# user id
	#
	jsonparser_get_key_value '%"token"%"user"%"id"%' "${_DBAAS_OP_TOKEN_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"token\"->\"user\"->\"id\" key in response body."
		rm -f "${_DBAAS_OP_TOKEN_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_USER_ID=${JSONPARSER_FIND_STR_VAL}

	#
	# user name
	#
	jsonparser_get_key_value '%"token"%"user"%"name"%' "${_DBAAS_OP_TOKEN_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"token\"->\"user\"->\"name\" key in response body."
		rm -f "${_DBAAS_OP_TOKEN_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_USER=${JSONPARSER_FIND_STR_VAL}

	#------------------------------------------------------
	# Check Scoped Token and Tenant
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		...
	#		...
	#		"token": {
	#			"project": {
	#				"domain": {
	#					"id": "default",
	#					"name": "Default"
	#				},
	#				"id": "<tenant id>",
	#				"name": "<tenant name>"
	#			}
	#		}
	#	}
	#
	_DBAAS_OP_TENANT=
	_DBAAS_OP_TENANT_ID=

	#
	# project -> Scoped Token
	#
	jsonparser_get_key_value '%"token"%"project"%' "${_DBAAS_OP_TOKEN_PAERSED_FILE}"
	if [ $? -eq 0 ]; then
		#
		# tenant id
		#
		jsonparser_get_key_value '%"token"%"project"%"id"%' "${_DBAAS_OP_TOKEN_PAERSED_FILE}"
		if [ $? -eq 0 ]; then
			_DBAAS_OP_TENANT_ID=${JSONPARSER_FIND_STR_VAL}

			#
			# tenant name
			#
			jsonparser_get_key_value '%"token"%"project"%"name"%' "${_DBAAS_OP_TOKEN_PAERSED_FILE}"
			if [ $? -eq 0 ]; then
				_DBAAS_OP_TENANT=${JSONPARSER_FIND_STR_VAL}
			else
				prn_warn "OpenStack token is scoped token, but there is no tenant name"
				_DBAAS_OP_TENANT_ID=
			fi
		else
			prn_warn "OpenStack token is scoped token, but there is no tenant id"
		fi
	else
		prn_dbg "(get_op_token_info) OpenStack token is unscoped token.."
	fi
	rm -f "${_DBAAS_OP_TOKEN_PAERSED_FILE}"

	#------------------------------------------------------
	# Get Urls when scoped token
	#------------------------------------------------------
	if [ "X${_DBAAS_OP_TENANT}" != "X" ] && [ "X${_DBAAS_OP_TENANT_ID}" != "X" ]; then
		get_op_service_eps "$1"
		if [ $? -ne 0 ]; then
			prn_warn "Failed to set(get) OpenStack some service endpoints."
		fi
	fi

	#
	# Set variables
	#
	K2HR3CLI_OPENSTACK_USER=${_DBAAS_OP_USER}
	K2HR3CLI_OPENSTACK_USER_ID=${_DBAAS_OP_USER_ID}
	K2HR3CLI_OPENSTACK_TOKEN="$1"

	add_config_update_var "K2HR3CLI_OPENSTACK_USER"
	add_config_update_var "K2HR3CLI_OPENSTACK_USER_ID"
	add_config_update_var "K2HR3CLI_OPENSTACK_TOKEN"

	prn_dbg "(get_op_token_info) OpenStack Unscoped Token   = \"${K2HR3CLI_OPENSTACK_TOKEN}\"."
	prn_dbg "(get_op_token_info) OpenStack User             = \"${K2HR3CLI_OPENSTACK_USER}\"."
	prn_dbg "(get_op_token_info) OpenStack User Id          = \"${K2HR3CLI_OPENSTACK_USER_ID}\"."

	if [ "X${_DBAAS_OP_TENANT}" != "X" ] && [ "X${_DBAAS_OP_TENANT_ID}" != "X" ]; then
		K2HR3CLI_OPENSTACK_TENANT=${_DBAAS_OP_TENANT}
		K2HR3CLI_OPENSTACK_TENANT_ID=${_DBAAS_OP_TENANT_ID}
		K2HR3CLI_OPENSTACK_SCOPED_TOKEN="$1"

		add_config_update_var "K2HR3CLI_OPENSTACK_TENANT"
		add_config_update_var "K2HR3CLI_OPENSTACK_TENANT_ID"
		add_config_update_var "K2HR3CLI_OPENSTACK_SCOPED_TOKEN"

		prn_dbg "(get_op_token_info) OpenStack Tenant           = \"${K2HR3CLI_OPENSTACK_TENANT}\"."
		prn_dbg "(get_op_token_info) OpenStack Tenant Id        = \"${K2HR3CLI_OPENSTACK_TENANT_ID}\"."
		prn_dbg "(get_op_token_info) OpenStack Scoped Token     = \"${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}\"."
	fi

	return 0
}

#
# Get OpenStack Unscoped Token from Credential
#
# $1	: openstack user name
# $2	: openstack user passphrase
# $?	: result
#
# Set Variables
#	K2HR3CLI_OPENSTACK_USER			: user name
#	K2HR3CLI_OPENSTACK_USER_ID		: user id
#	K2HR3CLI_OPENSTACK_PASS			: user id
#	K2HR3CLI_OPENSTACK_TOKEN		: valid token (unscoped token)
#
get_op_utoken()
{
	if [ "X${K2HR3CLI_OPENSTACK_IDENTITY_URI}" = "X" ]; then
		prn_err "OpenStack(Identity) URI is not specified. Please specify with the ${K2HR3CLI_COMMAND_OPT_OPENSTACK_IDENTITY_URI_LONG} option, K2HR3CLI_OPENSTACK_IDENTITY_URI environment variable, or configuration."
		return 1
	fi
	if [ "X$1" = "X" ] || [ "X$2" = "X" ]; then
		return 1
	fi

	#------------------------------------------------------
	# Send request for get unscoped token
	#------------------------------------------------------
	# [MEMO]
	#	http://<OpenStack Identity URI>/v3/auth/tokens?nocatalog
	#
	#	("nocatalog" argument is supported after Havana)
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_IDENTITY_URI}
	# shellcheck disable=SC2034
	K2HR3CLI_CURL_RESHEADER=1
	_DBAAS_OP_REQUEST_BODY="{\"auth\":{\"identity\":{\"password\":{\"user\":{\"domain\":{\"id\":\"default\"},\"password\":\"$2\",\"name\":\"$1\"}},\"methods\":[\"password\"]}}}"
	_DBAAS_OP_URL_PATH="/v3/auth/tokens?nocatalog"

	post_string_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""
	# shellcheck disable=SC2034
	K2HR3CLI_CURL_RESHEADER=0

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESHEADER_FILE}"
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201" 1
	if [ $? -ne 0 ]; then
		prn_dbg "(get_op_utoken) Could not get unscoped token from existed token for openstack."
		rm -f "${K2HR3CLI_REQUEST_RESHEADER_FILE}"
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Parse uscoped token
	#------------------------------------------------------
	# [MEMO]
	#	X-Subject-Token: <unscoped token>
	#
	_DBAAS_OP_UTOKEN=$(grep '^X-Subject-Token:' "${K2HR3CLI_REQUEST_RESHEADER_FILE}" | sed -e 's/X-Subject-Token:[ ]*//g' | tr -d '\r' | tr -d '\n')
	if [ $? -ne 0 ]; then
		prn_warn "Failed to get unscoped token for OpenStack."
		rm -f "${K2HR3CLI_REQUEST_RESHEADER_FILE}"
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${_DBAAS_OP_UTOKEN}" = "X" ]; then
		prn_warn "Got unscoped token for OpenStack is empty."
		rm -f "${K2HR3CLI_REQUEST_RESHEADER_FILE}"
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESHEADER_FILE}"

	#------------------------------------------------------
	# Get user id in result(parse result)
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		"token": {
	#			"methods": ["password"], 
	#			"user": {
	#				"domain": {
	#					"id": "default", 
	#					"name": "Default"
	#				}, 
	#				"id": "<User ID>", 
	#				"name": "<User Name>", 
	#				"password_expires_at": null
	#			}, 
	#			"audit_ids": ["...."], 
	#			"expires_at": "2021-01-01T00:00:00.000000Z", 
	#			"issued_at": "2021-01-01T00:00:00.000000Z"
	#		}
	#	}
	#
	jsonparser_get_key_value '%"token"%"user"%"name"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"token\"->\"user\"->\"name\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_USER=${JSONPARSER_FIND_STR_VAL}

	jsonparser_get_key_value '%"token"%"user"%"id"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"token\"->\"user\"->\"id\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_USER_ID=${JSONPARSER_FIND_STR_VAL}

	rm -f "${JP_PAERSED_FILE}"

	#
	# Success
	#
	K2HR3CLI_OPENSTACK_USER=${_DBAAS_OP_USER}
	K2HR3CLI_OPENSTACK_USER_ID=${_DBAAS_OP_USER_ID}
	K2HR3CLI_OPENSTACK_TOKEN=${_DBAAS_OP_UTOKEN}
	K2HR3CLI_OPENSTACK_PASS="$2"

	add_config_update_var "K2HR3CLI_OPENSTACK_USER"
	add_config_update_var "K2HR3CLI_OPENSTACK_USER_ID"
	add_config_update_var "K2HR3CLI_OPENSTACK_TOKEN"
	if [ "X${K2HR3CLI_OPT_SAVE_PASS}" = "X1" ] && [ "X${K2HR3CLI_PASS}" != "X" ]; then
		add_config_update_var "K2HR3CLI_OPENSTACK_PASS"
	fi

	prn_dbg "(get_op_utoken) OpenStack User           = \"${K2HR3CLI_OPENSTACK_USER}\"."
	prn_dbg "(get_op_utoken) OpenStack User ID        = \"${K2HR3CLI_OPENSTACK_USER_ID}\"."
	prn_dbg "(get_op_utoken) OpenStack Passphrase     = \"********(${#K2HR3CLI_OPENSTACK_PASS})\"."
	prn_dbg "(get_op_utoken) OpenStack Unscoped Token = \"${K2HR3CLI_OPENSTACK_TOKEN}\"."

	return 0
}

#
# Get OpenStack Scoped Token
#
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_TOKEN		: unscoped token
#	K2HR3CLI_OPENSTACK_TENANT		: tenant
#	K2HR3CLI_OPENSTACK_TENANT_ID	: tenant id
#
# Set Variables
#	K2HR3CLI_OPENSTACK_SCOPED_TOKEN	: valid scoped token
#	K2HR3CLI_OPENSTACK_NOVA_URI		: endpoint uri for nova
#	K2HR3CLI_OPENSTACK_GLANCE_URI	: endpoint uri for glance
#	K2HR3CLI_OPENSTACK_NEUTRON_URI	: endpoint uri for neutron
#
get_op_token()
{
	if [ "X${K2HR3CLI_OPENSTACK_IDENTITY_URI}" = "X" ]; then
		prn_err "OpenStack(Identity) URI is not specified. Please specify with the ${K2HR3CLI_COMMAND_OPT_OPENSTACK_IDENTITY_URI_LONG} option, K2HR3CLI_OPENSTACK_IDENTITY_URI environment variable, or configuration."
		return 1
	fi
	if [ "X${K2HR3CLI_OPENSTACK_TOKEN}" = "X" ] || [ "X${K2HR3CLI_OPENSTACK_TENANT_ID}" = "X" ]; then
		return 1
	fi

	#------------------------------------------------------
	# Send request for get scoped token
	#------------------------------------------------------
	# [MEMO]
	#	http://<OpenStack Identity URI>/v3/auth/tokens?nocatalog
	#
	#	("nocatalog" argument is supported after Havana)
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_IDENTITY_URI}
	# shellcheck disable=SC2034
	K2HR3CLI_CURL_RESHEADER=1
	_DBAAS_OP_REQUEST_BODY="{\"auth\":{\"identity\":{\"methods\":[\"token\"],\"token\":{\"id\":\"${K2HR3CLI_OPENSTACK_TOKEN}\"}},\"scope\":{\"project\":{\"id\":\"${K2HR3CLI_OPENSTACK_TENANT_ID}\"}}}}"
	_DBAAS_OP_URL_PATH="/v3/auth/tokens?nocatalog"

	post_string_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""
	# shellcheck disable=SC2034
	K2HR3CLI_CURL_RESHEADER=0

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESHEADER_FILE}"
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	_DBAAS_PAERSED_FILE="${JP_PAERSED_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${_DBAAS_PAERSED_FILE}" "201" 1
	if [ $? -ne 0 ]; then
		prn_dbg "(get_op_token) Could not get scoped token from unscoped token."
		rm -f "${K2HR3CLI_REQUEST_RESHEADER_FILE}"
		rm -f "${_DBAAS_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Parse scoped token
	#------------------------------------------------------
	# [MEMO]
	#	X-Subject-Token: <unscoped token>
	#
	_DBAAS_OP_TOKEN=$(grep '^X-Subject-Token:' "${K2HR3CLI_REQUEST_RESHEADER_FILE}" | sed -e 's/X-Subject-Token:[ ]*//g' | tr -d '\r' | tr -d '\n')
	if [ $? -ne 0 ]; then
		prn_warn "Failed to get scoped token for OpenStack."
		rm -f "${K2HR3CLI_REQUEST_RESHEADER_FILE}"
		rm -f "${_DBAAS_PAERSED_FILE}"
		return 1
	fi
	if [ "X${_DBAAS_OP_TOKEN}" = "X" ]; then
		prn_warn "Got scoped token for OpenStack is empty."
		rm -f "${K2HR3CLI_REQUEST_RESHEADER_FILE}"
		rm -f "${_DBAAS_PAERSED_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESHEADER_FILE}"
	rm -f "${_DBAAS_PAERSED_FILE}"

	#------------------------------------------------------
	# Check and Set service endpoints
	#------------------------------------------------------
	get_op_service_eps "${_DBAAS_OP_TOKEN}"

	#
	# Success
	#
	K2HR3CLI_OPENSTACK_SCOPED_TOKEN=${_DBAAS_OP_TOKEN}

	add_config_update_var "K2HR3CLI_OPENSTACK_SCOPED_TOKEN"

	prn_dbg "(get_op_token) OpenStack Scoped Token     = \"${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}\"."

	return 0
}

#
# Get OpenStack tenant id
#
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_TOKEN		: unscoped token
#	K2HR3CLI_OPENSTACK_USER_ID		: user id
#
# Set Variables
#	K2HR3CLI_OPENSTACK_TENANT		: tenant(scoped token)
#	K2HR3CLI_OPENSTACK_TENANT_ID	: tenant id
#
get_op_tenant_id()
{
	if [ "X${K2HR3CLI_OPENSTACK_IDENTITY_URI}" = "X" ]; then
		prn_err "OpenStack(Identity) URI is not specified. Please specify with the ${K2HR3CLI_COMMAND_OPT_OPENSTACK_IDENTITY_URI_LONG} option, K2HR3CLI_OPENSTACK_IDENTITY_URI environment variable, or configuration."
		return 1
	fi
	if [ "X${K2HR3CLI_OPENSTACK_TENANT}" != "X" ] && [ "X${K2HR3CLI_OPENSTACK_TENANT_ID}" != "X" ]; then
		return 0
	fi
	if [ "X${K2HR3CLI_OPENSTACK_TENANT}" = "X" ]; then
		return 1
	fi

	#------------------------------------------------------
	# Send request for get project(tenant) list
	#------------------------------------------------------
	# [MEMO]
	#	http://<OpenStack Identity URI>/v3/users/<user id>/projects
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_IDENTITY_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_TOKEN}"
	_DBAAS_OP_URL_PATH="/v3/users/${K2HR3CLI_OPENSTACK_USER_ID}/projects"

	get_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200" 1
	if [ $? -ne 0 ]; then
		prn_dbg "(get_op_tenant_id) Could not get tenant(project) list."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Search tenant id by name
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		"projects": [
	#			{
	#				"id": "<tenant id>", 
	#				"name": "<tenant name>", 
	#				"domain_id": "default", 
	#				"description": "", 
	#				"enabled": true, 
	#				"parent_id": "default", 
	#				"is_domain": false, 
	#				"tags": [], 
	#				"options": {}, 
	#				"links": {
	#					"self": "https://..."
	#				}
	#			},
	#			{...} 
	#		]
	#	}
	#
	jsonparser_get_key_value '%"projects"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"projects\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_PROJECT_LIST=${JSONPARSER_FIND_KEY_VAL}

	for _DBAAS_OP_PROJECT_POS in ${_DBAAS_OP_PROJECT_LIST}; do
		#
		# Check tenant name
		#
		_DBAAS_OP_PROJECT_POS_RAW=$(pecho -n "${_DBAAS_OP_PROJECT_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"projects\"%${_DBAAS_OP_PROJECT_POS_RAW}%\"name\"%" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			continue
		fi
		if [ "X${JSONPARSER_FIND_STR_VAL}" = "X${K2HR3CLI_OPENSTACK_TENANT}" ]; then
			#
			# Found same tenant name
			#
			jsonparser_get_key_value "%\"projects\"%${_DBAAS_OP_PROJECT_POS_RAW}%\"id\"%" "${JP_PAERSED_FILE}"
			if [ $? -ne 0 ]; then
				continue
			fi
			K2HR3CLI_OPENSTACK_TENANT_ID=${JSONPARSER_FIND_STR_VAL}

			add_config_update_var "K2HR3CLI_OPENSTACK_TENANT"
			add_config_update_var "K2HR3CLI_OPENSTACK_TENANT_ID"

			prn_dbg "(get_op_tenant_id) OpenStack Tenant      = \"${K2HR3CLI_OPENSTACK_TENANT}\"."
			prn_dbg "(get_op_tenant_id) OpenStack Tenant Id   = \"${K2HR3CLI_OPENSTACK_TENANT_ID}\"."

			rm -f "${JP_PAERSED_FILE}"
			return 0
		else
			#
			# Maybe K2HR3CLI_OPENSTACK_TENANT is an id, so check the id
			#
			_DBAAS_OP_PROJECT_TENANT_TMP=${JSONPARSER_FIND_STR_VAL}

			jsonparser_get_key_value "%\"projects\"%${_DBAAS_OP_PROJECT_POS_RAW}%\"id\"%" "${JP_PAERSED_FILE}"
			if [ $? -eq 0 ]; then
				if [ "X${JSONPARSER_FIND_STR_VAL}" = "X${K2HR3CLI_OPENSTACK_TENANT}" ]; then
					#
					# Found same tenant id
					#
					K2HR3CLI_OPENSTACK_TENANT=${_DBAAS_OP_PROJECT_TENANT_TMP}
					K2HR3CLI_OPENSTACK_TENANT_ID=${JSONPARSER_FIND_STR_VAL}

					add_config_update_var "K2HR3CLI_OPENSTACK_TENANT"
					add_config_update_var "K2HR3CLI_OPENSTACK_TENANT_ID"

					prn_dbg "(get_op_tenant_id) OpenStack Tenant      = \"${K2HR3CLI_OPENSTACK_TENANT}\"."
					prn_dbg "(get_op_tenant_id) OpenStack Tenant Id   = \"${K2HR3CLI_OPENSTACK_TENANT_ID}\"."

					rm -f "${JP_PAERSED_FILE}"
					return 0
				fi
			fi
		fi
	done

	rm -f "${JP_PAERSED_FILE}"

	return 1
}

#--------------------------------------------------------------
# Functions for OpenStack Neutron
#--------------------------------------------------------------
#
# Get security group name
#
# $1	: cluster name
# $2	: server(0: default)/slave(1)
# $?	: result
#
get_op_security_group_name()
{
	if [ "X$1" = "X" ]; then
		pecho -n ""
	fi
	if [ "X$2" = "X1" ]; then
		_DBAAS_OP_SECGRP_NAME="$1${K2HR3CLI_OPENSTACK_SLAVE_SECGRP_SUFFIX}"
	else
		_DBAAS_OP_SECGRP_NAME="$1${K2HR3CLI_OPENSTACK_SERVER_SECGRP_SUFFIX}"
	fi
	pecho -n "${_DBAAS_OP_SECGRP_NAME}"
}

#
# Check security group
#
# $1	: cluster name
# $2	: server(0: default)/slave(1)
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_NEUTRON_URI		: neutron uri
#
# Set Variables
#	K2HR3CLI_OPENSTACK_FIND_SECGRP_ID	: security group id
#
check_op_security_group()
{
	K2HR3CLI_OPENSTACK_FIND_SECGRP_ID=

	if [ "X${K2HR3CLI_OPENSTACK_NEUTRON_URI}" = "X" ]; then
		prn_err "OpenStack(Neutron) URI is not specified."
		return 1
	fi
	if [ "X$1" = "X" ]; then
		return 1
	fi
	_DBAAS_OP_SECGRP_NAME=$(get_op_security_group_name "$1" "$2")

	#------------------------------------------------------
	# Send request for get security group
	#------------------------------------------------------
	# [MEMO]
	#	http://<Neutron URI>/v2.0/security-groups?name=<security group name>&fields=id&fields=name
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NEUTRON_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
	_DBAAS_OP_URL_PATH="/v2.0/security-groups?name=${_DBAAS_OP_SECGRP_NAME}&fields=id&fields=name"

	get_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200" 1
	if [ $? -ne 0 ]; then
		prn_dbg "(check_security_group) Could not get security group list."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Search segurity group
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		"security_groups": [
	#			{
	#				"created_at": "2021-01-01T00:00:00Z",
	#				"description": "security group for k2hr3 server node",
	#				"id": "8fd53eb5-adaf-48ef-88f5-a61970bb03f5",
	#				"name": "mycluster-k2hdkc-server-sec",					<---- Check this
	#				"project_id": "a0b790a86c5544b7bb8c5acf53e59e0a",
	#				"revision_number": 1,
	#				"security_group_rules": [
	#					{
	#						"created_at": "2021-01-01T00:00:00Z",
	#						"description": "k2hdkc/chmpx server node port",
	#						"direction": "ingress",
	#						"ethertype": "IPv4",
	#						"id": "dac59a32-dd05-40ea-a208-7fc4bc9c68f2",
	#						"port_range_max": 8020,
	#						"port_range_min": 8020,
	#						"project_id": "a0b790a86c5544b7bb8c5acf53e59e0a",
	#						"protocol": "tcp",
	#						"remote_group_id": null,
	#						"remote_ip_prefix": "0.0.0.0/0",
	#						"revision_number": 0,
	#						"security_group_id": "8fd53eb5-adaf-48ef-88f5-a61970bb03f5",
	#						"tags": [],
	#						"tenant_id": "......",
	#						"updated_at": "2021-01-01T00:00:00Z"
	#				  },
	#				  {...}
	#				],
	#				"stateful": true,
	#				"tags": [],
	#				"tenant_id": ".....",
	#				"updated_at": "2021-01-01T00:00:00Z"
	#			}
	#		]
	#	}
	#
	jsonparser_get_key_value '%"security_groups"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"security_groups\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_SECGRP_LIST=${JSONPARSER_FIND_KEY_VAL}

	for _DBAAS_OP_SECGRP_POS in ${_DBAAS_OP_SECGRP_LIST}; do
		#
		# Check security groups name
		#
		_DBAAS_OP_SECGRP_POS_RAW=$(pecho -n "${_DBAAS_OP_SECGRP_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"security_groups\"%${_DBAAS_OP_SECGRP_POS_RAW}%\"name\"%" "${JP_PAERSED_FILE}"
		if [ $? -eq 0 ]; then
			if [ "X${JSONPARSER_FIND_STR_VAL}" = "X${_DBAAS_OP_SECGRP_NAME}" ]; then
				#
				# Found same security group name
				#
				jsonparser_get_key_value "%\"security_groups\"%${_DBAAS_OP_SECGRP_POS_RAW}%\"id\"%" "${JP_PAERSED_FILE}"
				if [ $? -ne 0 ]; then
					prn_warn "\"security_groups\"->\"id\" value in response body is somthing wrong."
					return 1
				fi
				K2HR3CLI_OPENSTACK_FIND_SECGRP_ID=${JSONPARSER_FIND_STR_VAL}

				prn_dbg "(check_security_group) Found secury group."
				rm -f "${JP_PAERSED_FILE}"
				return 0
			fi
		fi
	done

	rm -f "${JP_PAERSED_FILE}"

	return 1
}

#
# Create security group(if not exists)
#
# $1	: cluster name
# $2	: server(0: default)/slave(1)
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_NEUTRON_URI	: neutron uri
#	K2HR3CLI_OPENSTACK_TENANT_ID	: tenant id
#
# Set Variables
#	K2HR3CLI_OPENSTACK_SERVER_SECGRP		: security group name for server
#	K2HR3CLI_OPENSTACK_SLAVE_SECGRP			: security group name for slave
#
# [NOTE]
# This function does not check existing security groups.
# Please check before calling.
#
create_op_security_group()
{
	if [ "X${K2HR3CLI_OPENSTACK_NEUTRON_URI}" = "X" ]; then
		prn_err "OpenStack(Neutron) URI is not specified."
		return 1
	fi
	if [ "X${K2HR3CLI_OPENSTACK_TENANT_ID}" = "X" ]; then
		prn_err "OpenStack Project(tenant) id is not specified."
		return 1
	fi
	if [ "X$1" = "X" ]; then
		return 1
	fi
	if [ "X$2" = "X1" ]; then
		_DBAAS_OP_SECGRP_TYPE="slave"
	else
		_DBAAS_OP_SECGRP_TYPE="server"
	fi

	#
	# Secutiry Group Name
	#
	_DBAAS_OP_SECGRP_NAME=$(get_op_security_group_name "$1" "$2")

	#------------------------------------------------------
	# Send request for create security group
	#------------------------------------------------------
	# [MEMO]
	#	http://<Neutron URI>/v2.0/security-groups
	#
	#	{
	#		"security_groups": [
	#			{
	#				"name": "<cluster name>-k2hdkc-[server|slave]-sec",
	#				"description": "security group for k2hdkc [server|slave] node",
	#				"stateful": true,												<---- old version openstack(neutron) don't understand this.
	#				"project_id": "....<tenant id>...."
	#			}
	#		]
	#	}
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NEUTRON_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
	_DBAAS_OP_REQUEST_BODY="{\"security_groups\":[{\"name\":\"${_DBAAS_OP_SECGRP_NAME}\",\"description\":\"security group for k2hdkc $1 ${_DBAAS_OP_SECGRP_TYPE} node\",\"project_id\":\"${K2HR3CLI_OPENSTACK_TENANT_ID}\"}]}"
	_DBAAS_OP_URL_PATH="/v2.0/security-groups"

	post_string_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201" 1
	if [ $? -ne 0 ]; then
		prn_dbg "(create_op_security_group) Failed to create security group."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Search segurity group id
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		"security_groups": [
	#			{
	#				"created_at": "2021-01-01T00:00:00Z",
	#				"description": "security group for k2hdkc [server|slave] node",
	#	***			"id": "......<security group id>......",
	#				"name": "<cluster name>-k2hdkc-[server|slave]-sec",
	#				"project_id": "...<tenant id>...",
	#				"revision_number": 1,
	#				"security_group_rules": [
	#					{...}
	#				],
	#				"stateful": true,
	#				"tags": [],
	#				"tenant_id": "...<tenant id>...",
	#				"updated_at": "2021-01-01T00:00:00Z"
	#			}
	#		]
	#	}
	#
	jsonparser_get_key_value '%"security_groups"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"security_groups\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_SECGRP_LIST=${JSONPARSER_FIND_KEY_VAL}
	_DBAAS_OP_SECGRP_ID=""

	for _DBAAS_OP_SECGRP_POS in ${_DBAAS_OP_SECGRP_LIST}; do
		#
		# Check security groups id
		#
		_DBAAS_OP_SECGRP_POS_RAW=$(pecho -n "${_DBAAS_OP_SECGRP_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"security_groups\"%${_DBAAS_OP_SECGRP_POS_RAW}%\"id\"%" "${JP_PAERSED_FILE}"
		if [ $? -eq 0 ]; then
			#
			# Found id
			#
			_DBAAS_OP_SECGRP_ID=${JSONPARSER_FIND_STR_VAL}
			break
		fi
	done
	if [ "X${_DBAAS_OP_SECGRP_ID}" = "X" ]; then
		prn_warn "Not found \"security_groups\"->\"id\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#------------------------------------------------------
	# Create security rules for security group
	#------------------------------------------------------
	# [MEMO]
	#	http://<Neutron URI>/v2.0/security-group-rules
	#
	#	{
	#		"security_group_rule": {
	#			"description": "k2hdkc/chmpx [server|slave] node (control) port",
	#			"protocol": "tcp",
	#			"direction": "ingress",
	#			"ethertype": "IPv4",
	#			"port_range_max": <port number>,
	#			"port_range_min": <port number>,
	#			"remote_group_id": null,
	#			"security_group_id": "...<security group id>..."
	#		}
	#	}
	#
	if [ "X${_DBAAS_OP_SECGRP_TYPE}" = "Xserver" ]; then
		#
		# Send request for create security rule for server port
		#
		# shellcheck disable=SC2034
		K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NEUTRON_URI}
		_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
		_DBAAS_OP_REQUEST_BODY="{\"security_group_rule\":{\"description\":\"k2hdkc/chmpx ${_DBAAS_OP_SECGRP_TYPE} node port\",\"protocol\":\"tcp\",\"direction\":\"ingress\",\"ethertype\":\"IPv4\",\"port_range_max\":${K2HR3CLI_OPT_DBAAS_SERVER_PORT},\"port_range_min\":${K2HR3CLI_OPT_DBAAS_SERVER_PORT},\"remote_group_id\":null,\"security_group_id\":\"${_DBAAS_OP_SECGRP_ID}\"}}"
		_DBAAS_OP_URL_PATH="/v2.0/security-group-rules"

		post_string_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
		_DBAAS_REQUEST_RESULT=$?
		# shellcheck disable=SC2034
		K2HR3CLI_OVERRIDE_URI=""

		#
		# Parse response body
		#
		jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to parse result."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
			return 1
		fi
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

		#
		# Check result
		#
		requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201" 1
		if [ $? -ne 0 ]; then
			prn_dbg "(create_op_security_group) Failed to create security rule for server port."
			rm -f "${JP_PAERSED_FILE}"
			return 1
		fi
		rm -f "${JP_PAERSED_FILE}"

		#
		# Send request for create security rule for server control port
		#
		# shellcheck disable=SC2034
		K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NEUTRON_URI}
		_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
		_DBAAS_OP_REQUEST_BODY="{\"security_group_rule\":{\"description\":\"k2hdkc/chmpx ${_DBAAS_OP_SECGRP_TYPE} node control port\",\"protocol\":\"tcp\",\"direction\":\"ingress\",\"ethertype\":\"IPv4\",\"port_range_max\":${K2HR3CLI_OPT_DBAAS_SERVER_CTLPORT},\"port_range_min\":${K2HR3CLI_OPT_DBAAS_SERVER_CTLPORT},\"remote_group_id\":null,\"security_group_id\":\"${_DBAAS_OP_SECGRP_ID}\"}}"
		_DBAAS_OP_URL_PATH="/v2.0/security-group-rules"

		post_string_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
		_DBAAS_REQUEST_RESULT=$?
		# shellcheck disable=SC2034
		K2HR3CLI_OVERRIDE_URI=""

		#
		# Parse response body
		#
		jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to parse result."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
			return 1
		fi
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

		#
		# Check result
		#
		requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201" 1
		if [ $? -ne 0 ]; then
			prn_dbg "(create_op_security_group) Failed to create security rule for server control port."
			rm -f "${JP_PAERSED_FILE}"
			return 1
		fi
		rm -f "${JP_PAERSED_FILE}"

	else
		#
		# Send request for create security rule for slave control port
		#
		# shellcheck disable=SC2034
		K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NEUTRON_URI}
		_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
		_DBAAS_OP_REQUEST_BODY="{\"security_group_rule\":{\"description\":\"k2hdkc/chmpx ${_DBAAS_OP_SECGRP_TYPE} node control port\",\"protocol\":\"tcp\",\"direction\":\"ingress\",\"ethertype\":\"IPv4\",\"port_range_max\":${K2HR3CLI_OPT_DBAAS_SLAVE_CTLPORT},\"port_range_min\":${K2HR3CLI_OPT_DBAAS_SLAVE_CTLPORT},\"remote_group_id\":null,\"security_group_id\":\"${_DBAAS_OP_SECGRP_ID}\"}}"
		_DBAAS_OP_URL_PATH="/v2.0/security-group-rules"

		post_string_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
		_DBAAS_REQUEST_RESULT=$?
		# shellcheck disable=SC2034
		K2HR3CLI_OVERRIDE_URI=""

		#
		# Parse response body
		#
		jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to parse result."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
			return 1
		fi
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

		#
		# Check result
		#
		requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201" 1
		if [ $? -ne 0 ]; then
			prn_dbg "(create_op_security_group) Failed to create security rule for slave control port."
			rm -f "${JP_PAERSED_FILE}"
			return 1
		fi
		rm -f "${JP_PAERSED_FILE}"
	fi

	#
	# Set security group name
	#
	if [ "X$2" = "X1" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPENSTACK_SLAVE_SECGRP=${_DBAAS_OP_SECGRP_NAME}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_OPENSTACK_SERVER_SECGRP=${_DBAAS_OP_SECGRP_NAME}
	fi

	return 0
}

#
# Delete security group
#
# $1	: cluster name
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_NEUTRON_URI	: neutron uri
#
delete_op_security_groups()
{
	if [ "X${K2HR3CLI_OPENSTACK_NEUTRON_URI}" = "X" ]; then
		prn_err "OpenStack(Neutron) URI is not specified."
		return 1
	fi
	if [ "X$1" = "X" ]; then
		return 1
	fi

	#
	# Check server security group exists
	#
	check_op_security_group "$1" 0
	if [ $? -eq 0 ]; then
		#------------------------------------------------------
		# Send request for delete security group
		#------------------------------------------------------
		# [MEMO]
		#	http://<Neutron URI>/v2.0/security-groups/<security_group_id>
		#
		# shellcheck disable=SC2034
		K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NEUTRON_URI}
		_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
		_DBAAS_OP_URL_PATH="/v2.0/security-groups/${K2HR3CLI_OPENSTACK_FIND_SECGRP_ID}"

		delete_request "${_DBAAS_OP_URL_PATH}" 1 "${_DBAAS_OP_AUTH_HEADER}"

		_DBAAS_REQUEST_RESULT=$?
		# shellcheck disable=SC2034
		K2HR3CLI_OVERRIDE_URI=""

		#
		# Parse response body
		#
		jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to parse result."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
			return 1
		fi
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

		#
		# Check result
		#
		requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1
		if [ $? -ne 0 ]; then
			prn_dbg "(delete_op_security_group) Failed to delete server security group."
			rm -f "${JP_PAERSED_FILE}"
			return 1
		fi
		rm -f "${JP_PAERSED_FILE}"
	fi

	#
	# Check slave security group exists
	#
	check_op_security_group "$1" 1
	if [ $? -eq 0 ]; then
		#------------------------------------------------------
		# Send request for delete security group
		#------------------------------------------------------
		# [MEMO]
		#	http://<Neutron URI>/v2.0/security-groups/<security_group_id>
		#
		# shellcheck disable=SC2034
		K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NEUTRON_URI}
		_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
		_DBAAS_OP_URL_PATH="/v2.0/security-groups/${K2HR3CLI_OPENSTACK_FIND_SECGRP_ID}"

		delete_request "${_DBAAS_OP_URL_PATH}" 1 "${_DBAAS_OP_AUTH_HEADER}"
		_DBAAS_REQUEST_RESULT=$?
		# shellcheck disable=SC2034
		K2HR3CLI_OVERRIDE_URI=""

		#
		# Parse response body
		#
		jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to parse result."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
			return 1
		fi
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

		#
		# Check result
		#
		requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1
		if [ $? -ne 0 ]; then
			prn_dbg "(delete_op_security_group) Failed to delete slave security group."
			rm -f "${JP_PAERSED_FILE}"
			return 1
		fi
		rm -f "${JP_PAERSED_FILE}"
	fi

	return 0
}

#--------------------------------------------------------------
# Functions for OpenStack Keypair
#--------------------------------------------------------------
#
# Check Keypair
#
# $1	: keypair name
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_NOVA_URI	: nova uri(ex. http://xxx.xxx.xxx/compute/v2.1)
#
check_op_keypair()
{
	if [ "X${K2HR3CLI_OPENSTACK_NOVA_URI}" = "X" ]; then
		prn_err "OpenStack(Nova) URI is not specified."
		return 1
	fi
	if [ "X$1" = "X" ]; then
		return 1
	fi
	_DBAAS_OP_KEYPAIR_NAME="$1"

	#------------------------------------------------------
	# Send request for get keypair list
	#------------------------------------------------------
	# [MEMO]
	#	http://<Nova URI>/os-keypairs
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NOVA_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
	_DBAAS_OP_URL_PATH="/os-keypairs"

	get_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200" 1
	if [ $? -ne 0 ]; then
		prn_dbg "(check_op_keypair) Could not get keypair list."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Search keypair
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		"keypairs": [
	#			{
	#				"keypair": {
	#					"fingerprint": "xx:xx:xx:xx:xx....",
	#					"name": "<keypair name>",
	#					"public_key": "ssh-rsa ..........."
	#				}
	#			}
	#		]
	#	}
	#
	jsonparser_get_key_value '%"keypairs"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"keypairs\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_KEYPAIR_LIST=${JSONPARSER_FIND_KEY_VAL}

	for _DBAAS_OP_KEYPAIR_POS in ${_DBAAS_OP_KEYPAIR_LIST}; do
		#
		# Check keypair name
		#
		_DBAAS_OP_KEYPAIR_POS_RAW=$(pecho -n "${_DBAAS_OP_KEYPAIR_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"keypairs\"%${_DBAAS_OP_KEYPAIR_POS_RAW}%\"keypair\"%\"name\"%" "${JP_PAERSED_FILE}"
		if [ $? -eq 0 ]; then
			if [ "X${JSONPARSER_FIND_STR_VAL}" = "X${_DBAAS_OP_KEYPAIR_NAME}" ]; then
				#
				# Found same name
				#
				prn_dbg "(check_op_keypair) Found keypair."
				rm -f "${JP_PAERSED_FILE}"
				return 0
			fi
		fi
	done

	rm -f "${JP_PAERSED_FILE}"

	return 1
}

#--------------------------------------------------------------
# Functions for OpenStack Flavor
#--------------------------------------------------------------
#
# Check flavor
#
# $1	: flavor name
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_NOVA_URI		: nova uri
#	K2HR3CLI_OPENSTACK_TENANT_ID	: tenant id
#
# Set Variables
#	K2HR3CLI_OPENSTACK_FLAVOR_ID			: flavor id
#
check_op_flavor()
{
	if [ "X${K2HR3CLI_OPENSTACK_NOVA_URI}" = "X" ]; then
		prn_err "OpenStack(Nova) URI is not specified."
		return 1
	fi
	if [ "X${K2HR3CLI_OPENSTACK_TENANT_ID}" = "X" ]; then
		prn_err "OpenStack Project(tenant) id is not specified."
		return 1
	fi
	if [ "X$1" = "X" ]; then
		return 1
	fi
	_DBAAS_OP_FLAVOR_NAME="$1"

	#------------------------------------------------------
	# Send request for get flavor list
	#------------------------------------------------------
	# [MEMO]
	#	http://<Nova URI>/flavors/detail
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NOVA_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
	_DBAAS_OP_URL_PATH="/flavors/detail"

	get_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200" 1
	if [ $? -ne 0 ]; then
		prn_dbg "(check_op_flavor) Could not get flavor list."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Search flavor
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		"flavors": [
	#			{
	#				"OS-FLV-DISABLED:disabled": false,
	#				"OS-FLV-EXT-DATA:ephemeral": 0,
	#				"disk": 10,
	#	***			"id": "<flavor id>",
	#				"links": [
	#					{
	#						"href": "http://<Nova URI>/<tenant id>/flavors/<flavor id>",
	#						"rel": "self"
	#					},
	#					{
	#						"href": "http://<Nova URI>/<tenant id>/flavors/<flavor id>",
	#						"rel": "bookmark"
	#					}
	#				],
	#	***			"name": "<flavor name>",
	#				"os-flavor-access:is_public": true,
	#				"ram": 2048,
	#				"rxtx_factor": 1.0,
	#				"swap": "",
	#				"vcpus": 2
	#			},
	#			{....}
	#		]
	#	}
	#
	jsonparser_get_key_value '%"flavors"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"flavors\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_FLAVOR_LIST=${JSONPARSER_FIND_KEY_VAL}

	for _DBAAS_OP_FLAVOR_POS in ${_DBAAS_OP_FLAVOR_LIST}; do
		#
		# Check flavor object name
		#
		_DBAAS_OP_FLAVOR_POS_RAW=$(pecho -n "${_DBAAS_OP_FLAVOR_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"flavors\"%${_DBAAS_OP_FLAVOR_POS_RAW}%\"name\"%" "${JP_PAERSED_FILE}"
		if [ $? -eq 0 ]; then
			if [ "X${JSONPARSER_FIND_STR_VAL}" = "X${_DBAAS_OP_FLAVOR_NAME}" ]; then
				#
				# Found same name -> get flavor id
				#
				jsonparser_get_key_value "%\"flavors\"%${_DBAAS_OP_FLAVOR_POS_RAW}%\"id\"%" "${JP_PAERSED_FILE}"
				if [ $? -eq 0 ]; then
					# shellcheck disable=SC2034
					K2HR3CLI_OPENSTACK_FLAVOR_ID=${JSONPARSER_FIND_STR_VAL}
					prn_dbg "(check_op_flavor) Found flavor."
					rm -f "${JP_PAERSED_FILE}"
					return 0
				else
					prn_warn "Found ${_DBAAS_OP_FLAVOR_NAME} flavor, but its id is not existed."
				fi
			fi
		fi
	done

	rm -f "${JP_PAERSED_FILE}"

	return 1
}

#
# List flavor
#
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_NOVA_URI		: nova uri
#	K2HR3CLI_OPENSTACK_TENANT_ID	: tenant id
#
display_op_flavor_list()
{
	if [ "X${K2HR3CLI_OPENSTACK_NOVA_URI}" = "X" ]; then
		prn_err "OpenStack(Nova) URI is not specified."
		return 1
	fi
	if [ "X${K2HR3CLI_OPENSTACK_TENANT_ID}" = "X" ]; then
		prn_err "OpenStack Project(tenant) id is not specified."
		return 1
	fi

	#------------------------------------------------------
	# Send request for get flavor list
	#------------------------------------------------------
	# [MEMO]
	#	http://<Nova URI>/flavors/detail
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NOVA_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
	_DBAAS_OP_URL_PATH="/flavors/detail"

	get_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200" 1
	if [ $? -ne 0 ]; then
		prn_dbg "(check_op_flavor) Could not get flavor list."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Display flavors
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		"flavors": [
	#			{
	#				"OS-FLV-DISABLED:disabled": false,
	#				"OS-FLV-EXT-DATA:ephemeral": 0,
	#				"disk": 10,
	#	***			"id": "<flavor id>",
	#				"links": [
	#					{
	#						"href": "http://<Nova URI>/<tenant id>/flavors/<flavor id>",
	#						"rel": "self"
	#					},
	#					{
	#						"href": "http://<Nova URI>/<tenant id>/flavors/<flavor id>",
	#						"rel": "bookmark"
	#					}
	#				],
	#	***			"name": "<flavor name>",
	#				"os-flavor-access:is_public": true,
	#				"ram": 2048,
	#				"rxtx_factor": 1.0,
	#				"swap": "",
	#				"vcpus": 2
	#			},
	#			{....}
	#		]
	#	}
	#
	jsonparser_get_key_value '%"flavors"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"flavors\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_FLAVOR_LIST=${JSONPARSER_FIND_KEY_VAL}

	#
	# Display Start
	#
	if [ "X${K2HR3CLI_OPT_JSON}" = "X1" ]; then
		pecho -n "["
	else
		_DBAAS_OP_DISPLAY_JSON="["
	fi

	_DBAAS_OP_DISPLAY_LINE=0
	for _DBAAS_OP_FLAVOR_POS in ${_DBAAS_OP_FLAVOR_LIST}; do
		#
		# Check flavor name
		#
		_DBAAS_OP_FLAVOR_POS_RAW=$(pecho -n "${_DBAAS_OP_FLAVOR_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"flavors\"%${_DBAAS_OP_FLAVOR_POS_RAW}%\"name\"%" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(display_op_flavor_list) flavors[${_DBAAS_OP_FLAVOR_POS_RAW}] does not have name element, skip it"
			continue
		fi
		_DBAAS_OP_FLAVOR_NAME=${JSONPARSER_FIND_STR_VAL}

		#
		# Check flavor id
		#
		jsonparser_get_key_value "%\"flavors\"%${_DBAAS_OP_FLAVOR_POS_RAW}%\"id\"%" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(display_op_flavor_list) flavors[${_DBAAS_OP_FLAVOR_POS_RAW}] flavor=${_DBAAS_OP_FLAVOR_NAME} does not have id element, skip it"
			continue
		fi
		_DBAAS_OP_FLAVOR_ID=${JSONPARSER_FIND_STR_VAL}

		#
		# Display
		#
		if [ "X${K2HR3CLI_OPT_JSON}" = "X1" ]; then
			if [ "${_DBAAS_OP_DISPLAY_LINE}" -eq 0 ]; then
				pecho ""
				_DBAAS_OP_DISPLAY_LINE=1
			else
				pecho ","
			fi
			pecho "    {"
			pecho "        \"name\": \"${_DBAAS_OP_FLAVOR_NAME}\","
			pecho "        \"id\": \"${_DBAAS_OP_FLAVOR_ID}\""
			pecho -n "    }"
		else
			if [ "${_DBAAS_OP_DISPLAY_LINE}" -eq 0 ]; then
				_DBAAS_OP_DISPLAY_JSON="${_DBAAS_OP_DISPLAY_JSON}{\"name\":\"${_DBAAS_OP_FLAVOR_NAME}\",\"id\":\"${_DBAAS_OP_FLAVOR_ID}\"}"
				_DBAAS_OP_DISPLAY_LINE=1
			else
				_DBAAS_OP_DISPLAY_JSON="${_DBAAS_OP_DISPLAY_JSON},{\"name\":\"${_DBAAS_OP_FLAVOR_NAME}\",\"id\":\"${_DBAAS_OP_FLAVOR_ID}\"}"
			fi
		fi
	done

	#
	# Display End
	#
	if [ "X${K2HR3CLI_OPT_JSON}" = "X1" ]; then
		if [ "${_DBAAS_OP_DISPLAY_LINE}" -eq 0 ]; then
			pecho "]"
		else
			pecho ""
			pecho "]"
		fi
	else
		_DBAAS_OP_DISPLAY_JSON="${_DBAAS_OP_DISPLAY_JSON}]"
		pecho "${_DBAAS_OP_DISPLAY_JSON}"
	fi

	rm -f "${JP_PAERSED_FILE}"

	return 0
}

#--------------------------------------------------------------
# Functions for OpenStack Image
#--------------------------------------------------------------
#
# Check image
#
# $1	: image name
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_GLANCE_URI	: glance uri
#
# Set Variables
#	K2HR3CLI_OPENSTACK_IMAGE_ID		: image id
#
check_op_image()
{
	if [ "X${K2HR3CLI_OPENSTACK_GLANCE_URI}" = "X" ]; then
		prn_err "OpenStack(Glance) URI is not specified."
		return 1
	fi
	if [ "X$1" = "X" ]; then
		return 1
	fi
	_DBAAS_OP_IMAGE_NAME="$1"

	#------------------------------------------------------
	# Send request for get image list
	#------------------------------------------------------
	# [MEMO]
	#	http://<Glance URI>/v2/images?name=<image name>
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_GLANCE_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"

	if pecho -n "${_DBAAS_OP_IMAGE_NAME}" | grep -q ":"; then
		# [NOTE]
		# If the image name contains a colon(:), glance will fail detection.
		# In this case, get all the images.(Performance is the worst)
		#
		_DBAAS_OP_URL_PATH="/v2/images"
	else
		_DBAAS_OP_ESCAPED_IMAGE_NAME=$(k2hr3cli_urlencode "${_DBAAS_OP_IMAGE_NAME}")
		_DBAAS_OP_URL_PATH="/v2/images?name=${_DBAAS_OP_ESCAPED_IMAGE_NAME}"
	fi

	get_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200" 1 2>/dev/null
	if [ $? -ne 0 ]; then
		prn_dbg "(check_op_image) Could not get flavor list."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Search image
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		"first": "/v2/images",
	#		"images": [
	#			{
	#				"checksum": "....",
	#				"container_format": "bare",
	#				"created_at": "2021-01-01T00:00:00Z",
	#				"disk_format": "qcow2",
	#				"file": "/v2/images/.../file",
	#	***			"id": "<image id>",
	#				"min_disk": 0,
	#				"min_ram": 0,
	#	***			"name": "<image name>",
	#				"os_hash_algo": "sha512",
	#				"os_hash_value": "...",
	#				"os_hidden": false,
	#				"owner": "...",
	#				"owner_specified.openstack.md5": "",
	#				"owner_specified.openstack.object": "...",
	#				"owner_specified.openstack.sha256": "",
	#				"protected": false,
	#				"schema": "/v2/schemas/image",
	#				"self": "/v2/images/...",
	#				"size": ...,
	#				"status": "active",
	#				"tags": [],
	#				"updated_at": "2021-01-01T00:00:00Z",
	#				"virtual_size": null,
	#				"visibility": "public"
	#			},
	#			{...}
	#		],
	#		"schema": "/v2/schemas/images"
	#	}
	#
	jsonparser_get_key_value '%"images"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"images\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_IMAGE_LIST=${JSONPARSER_FIND_KEY_VAL}

	for _DBAAS_OP_IMAGE_POS in ${_DBAAS_OP_IMAGE_LIST}; do
		#
		# Check image name
		#
		_DBAAS_OP_IMAGE_POS_RAW=$(pecho -n "${_DBAAS_OP_IMAGE_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"images\"%${_DBAAS_OP_IMAGE_POS_RAW}%\"name\"%" "${JP_PAERSED_FILE}"
		if [ $? -eq 0 ]; then
			if [ "X${JSONPARSER_FIND_STR_VAL}" = "X${_DBAAS_OP_IMAGE_NAME}" ]; then
				#
				# Found same name -> get image id
				#
				jsonparser_get_key_value "%\"images\"%${_DBAAS_OP_IMAGE_POS_RAW}%\"id\"%" "${JP_PAERSED_FILE}"
				if [ $? -eq 0 ]; then
					# shellcheck disable=SC2034
					K2HR3CLI_OPENSTACK_IMAGE_ID=${JSONPARSER_FIND_STR_VAL}
					prn_dbg "(check_op_image) Found image id."
					rm -f "${JP_PAERSED_FILE}"
					return 0
				else
					prn_warn "Found ${_DBAAS_OP_IMAGE_NAME} image name, but its id is not existed."
				fi
			fi
		fi
	done
	rm -f "${JP_PAERSED_FILE}"

	return 1
}

#
# List image
#
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_GLANCE_URI	: glance uri
#
display_op_image_list()
{
	if [ "X${K2HR3CLI_OPENSTACK_GLANCE_URI}" = "X" ]; then
		prn_err "OpenStack(Glance) URI is not specified."
		return 1
	fi

	#------------------------------------------------------
	# Send request for get image list
	#------------------------------------------------------
	# [MEMO]
	#	http://<Glance URI>/v2/images
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_GLANCE_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
	_DBAAS_OP_URL_PATH="/v2/images"

	get_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200" 1 2>/dev/null
	if [ $? -ne 0 ]; then
		prn_dbg "(check_op_image) Could not get flavor list."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Display images
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		"first": "/v2/images",
	#		"images": [
	#			{
	#				"checksum": "....",
	#				"container_format": "bare",
	#				"created_at": "2021-01-01T00:00:00Z",
	#				"disk_format": "qcow2",
	#				"file": "/v2/images/.../file",
	#	***			"id": "<image id>",
	#				"min_disk": 0,
	#				"min_ram": 0,
	#	***			"name": "<image name>",
	#				"os_hash_algo": "sha512",
	#				"os_hash_value": "...",
	#				"os_hidden": false,
	#				"owner": "...",
	#				"owner_specified.openstack.md5": "",
	#				"owner_specified.openstack.object": "...",
	#				"owner_specified.openstack.sha256": "",
	#				"protected": false,
	#				"schema": "/v2/schemas/image",
	#				"self": "/v2/images/...",
	#				"size": ...,
	#				"status": "active",
	#				"tags": [],
	#				"updated_at": "2021-01-01T00:00:00Z",
	#				"virtual_size": null,
	#				"visibility": "public"
	#			},
	#			{...}
	#		],
	#		"schema": "/v2/schemas/images"
	#	}
	#
	jsonparser_get_key_value '%"images"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"images\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DBAAS_OP_IMAGE_LIST=${JSONPARSER_FIND_KEY_VAL}

	#
	# Display Start
	#
	if [ "X${K2HR3CLI_OPT_JSON}" = "X1" ]; then
		pecho -n "["
	else
		_DBAAS_OP_DISPLAY_JSON="["
	fi

	_DBAAS_OP_DISPLAY_LINE=0
	for _DBAAS_OP_IMAGE_POS in ${_DBAAS_OP_IMAGE_LIST}; do
		#
		# Check image name
		#
		_DBAAS_OP_IMAGE_POS_RAW=$(pecho -n "${_DBAAS_OP_IMAGE_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"images\"%${_DBAAS_OP_IMAGE_POS_RAW}%\"name\"%" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(display_op_image_list) images[${_DBAAS_OP_IMAGE_POS_RAW}] does not have name element, skip it"
			continue
		fi
		_DBAAS_OP_IMAGE_NAME=${JSONPARSER_FIND_STR_VAL}

		#
		# Check image id
		#
		jsonparser_get_key_value "%\"images\"%${_DBAAS_OP_IMAGE_POS_RAW}%\"id\"%" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(display_op_image_list) images[${_DBAAS_OP_IMAGE_POS_RAW}] name=${_DBAAS_OP_IMAGE_NAME} does not have id element, skip it"
		fi
		_DBAAS_OP_IMAGE_ID=${JSONPARSER_FIND_STR_VAL}

		#
		# Display
		#
		if [ "X${K2HR3CLI_OPT_JSON}" = "X1" ]; then
			if [ "${_DBAAS_OP_DISPLAY_LINE}" -eq 0 ]; then
				pecho ""
				_DBAAS_OP_DISPLAY_LINE=1
			else
				pecho ","
			fi
			pecho "    {"
			pecho "        \"name\": \"${_DBAAS_OP_IMAGE_NAME}\","
			pecho "        \"id\": \"${_DBAAS_OP_IMAGE_ID}\""
			pecho -n "    }"
		else
			if [ "${_DBAAS_OP_DISPLAY_LINE}" -eq 0 ]; then
				_DBAAS_OP_DISPLAY_JSON="${_DBAAS_OP_DISPLAY_JSON}{\"name\":\"${_DBAAS_OP_IMAGE_NAME}\",\"id\":\"${_DBAAS_OP_IMAGE_ID}\"}"
				_DBAAS_OP_DISPLAY_LINE=1
			else
				_DBAAS_OP_DISPLAY_JSON="${_DBAAS_OP_DISPLAY_JSON},{\"name\":\"${_DBAAS_OP_IMAGE_NAME}\",\"id\":\"${_DBAAS_OP_IMAGE_ID}\"}"
			fi
		fi
	done

	#
	# Display End
	#
	if [ "X${K2HR3CLI_OPT_JSON}" = "X1" ]; then
		if [ "${_DBAAS_OP_DISPLAY_LINE}" -eq 0 ]; then
			pecho "]"
		else
			pecho ""
			pecho "]"
		fi
	else
		_DBAAS_OP_DISPLAY_JSON="${_DBAAS_OP_DISPLAY_JSON}]"
		pecho "${_DBAAS_OP_DISPLAY_JSON}"
	fi

	rm -f "${JP_PAERSED_FILE}"

	return 0
}

#--------------------------------------------------------------
# Functions for Launch host
#--------------------------------------------------------------
#
# Create host
#
# $1	: post data
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_NOVA_URI		: nova uri
#	K2HR3CLI_OPENSTACK_TENANT_ID	: tenant id
#
# Set Variables
#	K2HR3CLI_OPENSTACK_CREATED_SERVER_ID	: server id
#
create_op_host()
{
	# shellcheck disable=SC2034
	K2HR3CLI_OPENSTACK_CREATED_SERVER_ID=

	if [ "X${K2HR3CLI_OPENSTACK_NOVA_URI}" = "X" ]; then
		prn_err "OpenStack(Neutron) URI is not specified."
		return 1
	fi
	if [ "X${K2HR3CLI_OPENSTACK_TENANT_ID}" = "X" ]; then
		prn_err "OpenStack Project(tenant) id is not specified."
		return 1
	fi
	if [ "X$1" = "X" ]; then
		prn_err "OpenStack post data for launching is empty."
		return 1
	fi

	#------------------------------------------------------
	# Send request for create host
	#------------------------------------------------------
	# [MEMO]
	#	http://<Nova URI>/servers
	#
	#	{
	#		"server":{
	#			"imageRef":"...",
	#			"flavorRef":"...",
	#			"name":"...",
	#			"user_data":"...<base64>...",
	#			"security_groups": [
	#				{
	#					"name": "default"
	#				},
	#				{
	#					"name": "..."
	#				}
	#			],
	#			"key_name":"..."
	#		}
	#	}
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NOVA_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
	_DBAAS_OP_REQUEST_BODY="$1"
	_DBAAS_OP_URL_PATH="/servers"

	post_string_request "${_DBAAS_OP_URL_PATH}" "${_DBAAS_OP_REQUEST_BODY}" 1 "${_DBAAS_OP_AUTH_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "202" 1
	if [ $? -ne 0 ]; then
		prn_dbg "(create_op_host) Failed to create host."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#------------------------------------------------------
	# Search segurity group id
	#------------------------------------------------------
	# [MEMO]
	#	{
	#		"server": {
	#	***		"id": "...", 
	#			"links": [
	#				{
	#					"rel": "self", 
	#					"href": "http://<Nova URI>/<tenant id>/servers/<server id>"
	#				}, 
	#				{
	#					"rel": "bookmark", 
	#					"href": "http://<Nova URI>/<tenant id>/servers/<server id>"
	#				}
	#			], 
	#			"OS-DCF:diskConfig": "MANUAL", 
	#			"security_groups": [
	#				{...}
	#			], 
	#			"adminPass": "..."
	#		}
	#	}
	#
	jsonparser_get_key_value '%"server"%"id"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "Not found \"server\"->\"id\" key in response body."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	# shellcheck disable=SC2034
	K2HR3CLI_OPENSTACK_CREATED_SERVER_ID=${JSONPARSER_FIND_STR_VAL}
	rm -f "${JP_PAERSED_FILE}"

	return 0
}

#--------------------------------------------------------------
# Functions for Delete host
#--------------------------------------------------------------
#
# Delete host
#
# $1	: host id
# $?	: result
#
# Use Variables
#	K2HR3CLI_OPENSTACK_NOVA_URI		: nova uri
#
delete_op_host()
{
	if [ "X${K2HR3CLI_OPENSTACK_NOVA_URI}" = "X" ]; then
		prn_err "OpenStack(Nova) URI is not specified."
		return 1
	fi
	if [ "X$1" = "X" ]; then
		prn_dbg "(delete_op_host) Parameter is wrong."
		return 1
	fi

	#------------------------------------------------------
	# Send request for delete host
	#------------------------------------------------------
	# [MEMO]
	#	http://<Nova URI>/servers/<server id>
	#
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=${K2HR3CLI_OPENSTACK_NOVA_URI}
	_DBAAS_OP_AUTH_HEADER="X-Auth-Token:${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}"
	_DBAAS_OP_URL_PATH="/servers/$1"

	delete_request "${_DBAAS_OP_URL_PATH}" 1 "${_DBAAS_OP_AUTH_HEADER}"
	_DBAAS_REQUEST_RESULT=$?
	# shellcheck disable=SC2034
	K2HR3CLI_OVERRIDE_URI=""

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_DBAAS_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1
	if [ $? -ne 0 ]; then
		prn_dbg "(delete_op_host) Failed to delete host."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	rm -f "${JP_PAERSED_FILE}"

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
