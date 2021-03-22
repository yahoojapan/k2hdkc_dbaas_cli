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
#
# DBaaS Resoruce Template file name
#
_DATABASE_DEFAULT_CONFIG_FILENAME="k2hdkc_dbaas_resource.templ"
_DATABASE_DEFAULT_KEYS_FILENAME="k2hdkc_dbaas_resource_keys.config"

#
# The template for OpenStack Nova
#
_DATABASE_DEFAULT_CREATE_HOST_FILENAME="k2hdkc_dbaas_create_host.templ"

#--------------------------------------------------------------
# Functions
#--------------------------------------------------------------
#
# Get DBaaS Resoruce template file path
#
# $?						: result
# Output
#	_DATABASE_CONFIG_FILE	: Configuration file for resource template
#
dbaas_get_resource_filepath()
{
	_DATABASE_CONFIG_FILE=""

	if [ "X${K2HR3CLI_DBAAS_CONFIG}" != "X" ]; then
		#
		# Specified custom dbaas configuration directory
		#
		if [ -d "${K2HR3CLI_DBAAS_CONFIG}" ]; then
			if [ -f "${K2HR3CLI_DBAAS_CONFIG}/${_DATABASE_DEFAULT_CONFIG_FILENAME}" ]; then
				_DATABASE_CONFIG_FILE="${K2HR3CLI_DBAAS_CONFIG}/${_DATABASE_DEFAULT_CONFIG_FILENAME}"
			else
				prn_err "Specified K2HDKC DBaaS CLI Configuration(${K2HR3CLI_DBAAS_CONFIG}/${_DATABASE_DEFAULT_CONFIG_FILENAME}) is not existed."
				return 1
			fi
		else
			prn_err "Specified K2HDKC DBaaS CLI Configuration directory(${K2HR3CLI_DBAAS_CONFIG}) is not existed."
			return 1
		fi
	else
		#
		# Check user home dbaas configuration
		#
		_DATABASE_USER_CONFIG_DIR=$(config_get_default_user_dir)
		if [ -d "${_DATABASE_USER_CONFIG_DIR}" ]; then
			if [ -f "${_DATABASE_USER_CONFIG_DIR}/${_DATABASE_DEFAULT_CONFIG_FILENAME}" ]; then
				_DATABASE_CONFIG_FILE="${_DATABASE_USER_CONFIG_DIR}/${_DATABASE_DEFAULT_CONFIG_FILENAME}"
			fi
		fi

		if [ "X${_DATABASE_CONFIG_FILE}" = "X" ]; then
			#
			# Default dbaas configuration
			#
			if [ -d "${_DATABASE_CURRENT_DIR}" ]; then
				if [ -f "${_DATABASE_CURRENT_DIR}/${_DATABASE_DEFAULT_CONFIG_FILENAME}" ]; then
					_DATABASE_CONFIG_FILE="${_DATABASE_CURRENT_DIR}/${_DATABASE_DEFAULT_CONFIG_FILENAME}"
				else
					prn_err "Default K2HDKC DBaaS CLI Configuration(${_DATABASE_CURRENT_DIR}/${_DATABASE_DEFAULT_CONFIG_FILENAME}) is not existed."
					return 1
				fi
			else
				prn_err "Default K2HDKC DBaaS CLI Directory(${_DATABASE_CURRENT_DIR}) is not existed."
				return 1
			fi
		fi
	fi
	return 0
}

#
# Load DBaaS Resoruce keys
#
# $?						: result
# Output
#	DATABASE_SERVER_KEY_INI_PKG		: for "k2hr3-init-packages" key
#	DATABASE_SERVER_KEY_INI_PCPKG	: for "k2hr3-init-packagecloud-packages" key
#	DATABASE_SERVER_KEY_INI_SYSPKG	: for "k2hr3-init-systemd-packages" key
#
#	DATABASE_SLAVE_KEY_INI_PKG		: for "k2hr3-init-packages" key
#	DATABASE_SLAVE_KEY_INI_PCPKG	: for "k2hr3-init-packagecloud-packages" key
#	DATABASE_SLAVE_KEY_INI_SYSPKG	: for "k2hr3-init-systemd-packages" key
#
dbaas_load_resource_keys()
{
	_DATABASE_KEYS_FILE=""

	if [ "X${K2HR3CLI_DBAAS_CONFIG}" != "X" ]; then
		#
		# Specified custom dbaas configuration directory
		#
		if [ -d "${K2HR3CLI_DBAAS_CONFIG}" ]; then
			if [ -f "${K2HR3CLI_DBAAS_CONFIG}/${_DATABASE_DEFAULT_KEYS_FILENAME}" ]; then
				_DATABASE_KEYS_FILE="${K2HR3CLI_DBAAS_CONFIG}/${_DATABASE_DEFAULT_KEYS_FILENAME}"
			else
				prn_err "Specified K2HDKC DBaaS CLI Configuration(${K2HR3CLI_DBAAS_CONFIG}/${_DATABASE_DEFAULT_KEYS_FILENAME}) is not existed."
				return 1
			fi
		else
			prn_err "Specified K2HDKC DBaaS CLI Configuration directory(${K2HR3CLI_DBAAS_CONFIG}) is not existed."
			return 1
		fi
	else
		#
		# Check user home dbaas configuration
		#
		_DATABASE_USER_CONFIG_DIR=$(config_get_default_user_dir)
		if [ -d "${_DATABASE_USER_CONFIG_DIR}" ]; then
			if [ -f "${_DATABASE_USER_CONFIG_DIR}/${_DATABASE_DEFAULT_KEYS_FILENAME}" ]; then
				_DATABASE_KEYS_FILE="${_DATABASE_USER_CONFIG_DIR}/${_DATABASE_DEFAULT_KEYS_FILENAME}"
			fi
		fi

		if [ "X${_DATABASE_KEYS_FILE}" = "X" ]; then
			#
			# Default dbaas configuration
			#
			if [ -d "${_DATABASE_CURRENT_DIR}" ]; then
				if [ -f "${_DATABASE_CURRENT_DIR}/${_DATABASE_DEFAULT_KEYS_FILENAME}" ]; then
					_DATABASE_KEYS_FILE="${_DATABASE_CURRENT_DIR}/${_DATABASE_DEFAULT_KEYS_FILENAME}"
				else
					prn_warn "Default K2HDKC DBaaS CLI Configuration(${_DATABASE_CURRENT_DIR}/${_DATABASE_DEFAULT_KEYS_FILENAME}) is not existed."
				fi
			else
				prn_warn "Default K2HDKC DBaaS CLI Directory(${_DATABASE_CURRENT_DIR}) is not existed."
			fi
		fi
	fi

	#
	# Load values
	#
	if [ "X${_DATABASE_KEYS_FILE}" != "X" ]; then
		. "${_DATABASE_KEYS_FILE}"
	else
		#
		# File is not found, set default
		#
		DATABASE_SERVER_KEY_INI_PKG=""
		DATABASE_SERVER_KEY_INI_PCPKG="k2hdkc-dbaas-override-conf,k2hr3-get-resource,chmpx,k2hdkc"
		DATABASE_SERVER_KEY_INI_SYSPKG="chmpx.service,k2hdkc.service,k2hr3-get-resource.timer"
		DATABASE_SLAVE_KEY_INI_PKG=""
		DATABASE_SLAVE_KEY_INI_PCPKG="k2hdkc-dbaas-override-conf,k2hr3-get-resource,chmpx"
		DATABASE_SLAVE_KEY_INI_SYSPKG="chmpx.service,k2hr3-get-resource.timer"
	fi

	#
	# Check values(cut space)
	#
	DATABASE_SERVER_KEY_INI_PKG=$(pecho -n "${DATABASE_SERVER_KEY_INI_PKG}" | sed -e 's/ //g')
	DATABASE_SERVER_KEY_INI_PCPKG=$(pecho -n "${DATABASE_SERVER_KEY_INI_PCPKG}" | sed -e 's/ //g')
	DATABASE_SERVER_KEY_INI_SYSPKG=$(pecho -n "${DATABASE_SERVER_KEY_INI_SYSPKG}" | sed -e 's/ //g')
	DATABASE_SLAVE_KEY_INI_PKG=$(pecho -n "${DATABASE_SLAVE_KEY_INI_PKG}" | sed -e 's/ //g')
	DATABASE_SLAVE_KEY_INI_PCPKG=$(pecho -n "${DATABASE_SLAVE_KEY_INI_PCPKG}" | sed -e 's/ //g')
	DATABASE_SLAVE_KEY_INI_SYSPKG=$(pecho -n "${DATABASE_SLAVE_KEY_INI_SYSPKG}" | sed -e 's/ //g')

	return 0
}

#
# Get Current Tenant from Scoped Token
#
# $?		: result
# Output	: Tenant name
#
dbaas_get_current_tenant()
{
	if [ "X${K2HR3CLI_SCOPED_TOKEN}" = "X" ]; then
		return 1
	fi

	#
	# Run k2hr3 for token show
	#
	_DATABASE_TOKEN_INFO=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" token show token --scopedtoken "${K2HR3CLI_SCOPED_TOKEN}")
	if [ $? -ne 0 ]; then
		prn_err "Failed to get scoped token information."
		return 1
	fi

	#
	# Parse Result
	#
	jsonparser_parse_json_string "${_DATABASE_TOKEN_INFO}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse scoped token information."
		return 1
	fi

	#
	# Top element
	#
	jsonparser_get_key_value '%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse scoped token information."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_ARR}" ]; then
		prn_err "Scoped token information is not array."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL}" = "X" ]; then
		prn_err "Scoped token information is empty array."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#
	# Use only first element
	#
	_DATABASE_TOKEN_INFO_POS=$(pecho -n "${JSONPARSER_FIND_KEY_VAL}" | awk '{print $1}')
	_DATABASE_TOKEN_INFO_POS_RAW=$(pecho -n "${_DATABASE_TOKEN_INFO_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
	jsonparser_get_key_value "%${_DATABASE_TOKEN_INFO_POS_RAW}%\"name\"%" "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse scoped token information(element does not have \"name\")."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_STR}" ]; then
		prn_err "Failed to parse scoped token information(\"name\" is not string)."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_STR_VAL}" = "X" ]; then
		prn_err "Failed to parse scoped token information(\"name\" value is empty)."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	prn_dbg "(dbaas_get_current_tenant) Scoped Token Tenant is \"${JSONPARSER_FIND_STR_VAL}\""
	pecho -n "${JSONPARSER_FIND_STR_VAL}"

	return 0
}

#
# Search Role Token(Maximum expiration date)
#
# $1							: role name
# $?							: result
# Output
#	DBAAS_FOUND_ROLETOKEN		: found existed role token string
#	DBAAS_FOUND_REGISTERPATH	: found existed role token's registerpath
#
dbaas_get_existed_role_token()
{
	DBAAS_FOUND_ROLETOKEN=""
	DBAAS_FOUND_REGISTERPATH=""

	if [ $# -lt 1 ]; then
		return 1
	fi
	_DATABASE_GET_RTOKEN_ROLE=$1

	#
	# (1) Get Role Token list
	#
	# [MEMO]
	#	["49963578ddfe93dfa214e509426eb59f2fddfb4778bd47972d3fad2fe9c3a434","fdc09c83575df90e103d70ee9acb64d2085c96e425d296342dc7029b4abd091c"]
	#
	_DATABASE_GET_RTOKEN_ARR_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" role token show "${_DATABASE_GET_RTOKEN_ROLE}")

	#
	# Check Result
	#
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_get_existed_role_token) Role token for ${_DATABASE_GET_RTOKEN_ROLE} is not existed or failed to get those."
		return 1
	fi

	#
	# Parse Result
	#
	jsonparser_parse_json_string "${_DATABASE_GET_RTOKEN_ARR_RESULT}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_get_existed_role_token) Failed to parse Role token for ${_DATABASE_GET_RTOKEN_ROLE}."
		return 1
	fi
	jsonparser_get_key_value '%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_get_existed_role_token) Failed to parse Role token for ${_DATABASE_GET_RTOKEN_ROLE}."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_ARR}" ]; then
		prn_dbg "(dbaas_get_existed_role_token) Role token for ${_DATABASE_GET_RTOKEN_ROLE} is not array."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL}" = "X" ]; then
		prn_dbg "(dbaas_get_existed_role_token) Role token for ${_DATABASE_GET_RTOKEN_ROLE} is empty."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DATABASE_GET_RTOKEN_LIST_FILE=${JP_PAERSED_FILE}
	_DATABASE_GET_RTOKEN_POS_LIST=${JSONPARSER_FIND_KEY_VAL}

	#
	# (2) Get Role Token Details
	#
	# [MEMO]
	#	{
	#	    "....TOKEN STRING....": {
	#	        "date": "2021-01-01T00:00:00.000Z",
	#	        "expire": "2031-01-01T00:00:00.000Z",
	#	        "user": "user",
	#	        "hostname": null,
	#	        "ip": null,
	#	        "port": 0,
	#	        "cuk": null,
	#	        "registerpath": ".... path ...."
	#	    },
	#	    {...}
	#	}
	#
	_DATABASE_GET_RTOKEN_OBJ_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" role token show "${_DATABASE_GET_RTOKEN_ROLE}" --expand)

	#
	# Check Result
	#
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_get_existed_role_token) Role token for ${_DATABASE_GET_RTOKEN_ROLE} is not existed or failed to get those."
		rm -f "${_DATABASE_GET_RTOKEN_LIST_FILE}"
		return 1
	fi

	#
	# Parse Result
	#
	jsonparser_parse_json_string "${_DATABASE_GET_RTOKEN_OBJ_RESULT}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_get_existed_role_token) Failed to parse Role token detail for ${_DATABASE_GET_RTOKEN_ROLE}."
		return 1
	fi
	_DATABASE_GET_RTOKEN_OBJ_FILE="${JP_PAERSED_FILE}"

	#
	# Loop - Role Token List
	#
	_DATABASE_GET_RTOKEN_MAX_TOKEN=""
	_DATABASE_GET_RTOKEN_MAX_EXPIRE=0
	_DATABASE_GET_RTOKEN_MAX_REGPATH=""
	for _DATABASE_GET_RTOKEN_POS in ${_DATABASE_GET_RTOKEN_POS_LIST}; do
		#
		# Get token string from array
		#
		_DATABASE_GET_RTOKEN_POS_RAW=$(pecho -n "${_DATABASE_GET_RTOKEN_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%${_DATABASE_GET_RTOKEN_POS_RAW}%" "${_DATABASE_GET_RTOKEN_LIST_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to parse scoped token information at \"%${_DATABASE_GET_RTOKEN_POS_RAW}%\"."
			rm -f "${_DATABASE_GET_RTOKEN_OBJ_FILE}"
			rm -f "${_DATABASE_GET_RTOKEN_LIST_FILE}"
			return 1
		fi
		if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_STR}" ]; then
			prn_err "Failed to parse scoped token information at \"%${_DATABASE_GET_RTOKEN_POS_RAW}%\" is not string."
			continue
		fi
		if [ "X${JSONPARSER_FIND_VAL}" = "X" ]; then
			prn_err "Failed to parse scoped token information at \"%${_DATABASE_TOKEN_INFO_POS}%\" is empty string."
			continue
		fi
		_DATABASE_GET_RTOKEN_STR=${JSONPARSER_FIND_STR_VAL}
		_DATABASE_GET_RTOKEN_KEY=${JSONPARSER_FIND_VAL}

		#
		# Search token in object(registerpath)
		#
		jsonparser_get_key_value "%${_DATABASE_GET_RTOKEN_KEY}%\"registerpath\"%" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(dbaas_get_existed_role_token) ${_DATABASE_GET_RTOKEN_TOKENSTR} role token does not have registerpath key."
			continue
		fi
		if [ "X${JSONPARSER_FIND_STR_VAL}" = "X" ]; then
			prn_dbg "(dbaas_get_existed_role_token) ${_DATABASE_GET_RTOKEN_TOKENSTR} role token registerpath is empty."
			continue
		fi
		_DATABASE_GET_RTOKEN_REGISTERPATH=${JSONPARSER_FIND_STR_VAL}

		#
		# Search token in object(expire)
		#
		jsonparser_get_key_value "%${_DATABASE_GET_RTOKEN_KEY}%\"expire\"%" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(dbaas_get_existed_role_token) ${_DATABASE_GET_RTOKEN_TOKENSTR} role token does not have expire key."
			continue
		fi
		if [ "X${JSONPARSER_FIND_STR_VAL}" = "X" ]; then
			prn_dbg "(dbaas_get_existed_role_token) ${_DATABASE_GET_RTOKEN_TOKENSTR} role token expire is empty."
			continue
		fi
		_DATABASE_GET_RTOKEN_EXPIRE=${JSONPARSER_FIND_STR_VAL}

		#
		# Make expire number string
		#
		_DATABASE_GET_RTOKEN_EXPIRE_NUM=$(pecho -n "${_DATABASE_GET_RTOKEN_EXPIRE}" | sed -e 's/[.].*$//g' -e s'/[:]//g' -e s'/[-|+|T]//g')
		_DATABASE_GET_RTOKEN_MAX_EXPIRE_NUM=$(pecho -n "${_DATABASE_GET_RTOKEN_MAX_EXPIRE}" | sed -e 's/[.].*$//g' -e s'/[:]//g' -e s'/[-|+|T]//g')

		#
		# Compare
		#
		if [ "${_DATABASE_GET_RTOKEN_EXPIRE_NUM}" -gt "${_DATABASE_GET_RTOKEN_MAX_EXPIRE_NUM}" ]; then
			#
			# Detected role token with a longer expiration date
			#
			_DATABASE_GET_RTOKEN_MAX_TOKEN=$(pecho -n "${_DATABASE_GET_RTOKEN_STR}")
			_DATABASE_GET_RTOKEN_MAX_EXPIRE=$(pecho -n "${_DATABASE_GET_RTOKEN_EXPIRE}")
			_DATABASE_GET_RTOKEN_MAX_REGPATH=$(pecho -n "${_DATABASE_GET_RTOKEN_REGISTERPATH}")
		fi
	done

	rm -f "${_DATABASE_GET_RTOKEN_OBJ_FILE}"
	rm -f "${_DATABASE_GET_RTOKEN_LIST_FILE}"

	if [ "X${_DATABASE_GET_RTOKEN_MAX_TOKEN}" = "X" ] || [ "X${_DATABASE_GET_RTOKEN_MAX_REGPATH}" = "X" ]; then
		prn_dbg "(dbaas_get_existed_role_token) Not found existed Role token."
		return 1
	fi

	DBAAS_FOUND_ROLETOKEN=${_DATABASE_GET_RTOKEN_MAX_TOKEN}
	DBAAS_FOUND_REGISTERPATH=${_DATABASE_GET_RTOKEN_MAX_REGPATH}

	prn_dbg "(dbaas_get_existed_role_token) Found existed Role token              : ${DBAAS_FOUND_ROLETOKEN}"
	prn_dbg "(dbaas_get_existed_role_token) Found existed Role token Registerpath : ${DBAAS_FOUND_REGISTERPATH}"

	return 0
}

#
# Create New Role Token
#
# $1						: role name
# $?						: result
# Output
#	DBAAS_NEW_ROLETOKEN		: role token string
#	DBAAS_NEW_REGISTERPATH	: role token's registerpath
#
dbaas_create_role_token()
{
	if [ $# -lt 1 ]; then
		return 1
	fi
	_DATABASE_CREATE_RTOKEN_ROLE=$1

	#
	# (1) Get Role Token list
	#
	# [MEMO]
	#	Succeed :	ROLE TOKEN=......
	#				REGISTERPATH=......
	#
	_DATABASE_CREATE_RTOKEN_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" role token create "${_DATABASE_CREATE_RTOKEN_ROLE}" --expire "0")

	#
	# Check Result
	#
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_create_role_token) Failed to create new Role token for ${_DATABASE_GET_RTOKEN_ROLE}."
		return 1
	fi
	if [ "X${_DATABASE_CREATE_RTOKEN_RESULT}" = "X" ]; then
		prn_dbg "(dbaas_create_role_token) Failed to create new Role token for ${_DATABASE_GET_RTOKEN_ROLE}(result is empty)"
		return 1
	fi

	#
	# Parse Result
	#
	jsonparser_parse_json_string "${_DATABASE_CREATE_RTOKEN_RESULT}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_create_role_token) Failed to parse new Role token for ${_DATABASE_GET_RTOKEN_ROLE}"
		return 1
	fi

	jsonparser_get_key_value '%"token"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_create_role_token) Failed to create new Role token for ${_DATABASE_GET_RTOKEN_ROLE}(result token is wrong format)"
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DATABASE_CREATE_RTOKEN=${JSONPARSER_FIND_STR_VAL}

	jsonparser_get_key_value '%"registerpath"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_create_role_token) Failed to create new Role token for ${_DATABASE_GET_RTOKEN_ROLE}(result registerpath is wrong format)"
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DATABASE_CREATE_REGPATH=${JSONPARSER_FIND_STR_VAL}

	rm -f "${JP_PAERSED_FILE}"

	if [ "X${_DATABASE_CREATE_RTOKEN}" = "X" ] || [ "X${_DATABASE_CREATE_REGPATH}" = "X" ]; then
		prn_dbg "(dbaas_create_role_token) Failed to create new Role token for ${_DATABASE_GET_RTOKEN_ROLE}(result is something wrong)"
		return 1
	fi

	DBAAS_NEW_ROLETOKEN=${_DATABASE_CREATE_RTOKEN}
	DBAAS_NEW_REGISTERPATH=${_DATABASE_CREATE_REGPATH}

	prn_dbg "(dbaas_create_role_token) Created Role token              : ${DBAAS_NEW_ROLETOKEN}"
	prn_dbg "(dbaas_create_role_token) Created Role token Registerpath : ${DBAAS_NEW_REGISTERPATH}"

	return 0
}

#
# Get OpenStack Nova template
#
# $1						: server name
# $2						: image id
# $3						: flavor id
# $4						: user data
# $5						: keypair name(allow empty)
# $6						: security group name(allow empty)
# $?						: result
# Output					: json post data for launching host
#
dbaas_get_openstack_launch_post_data()
{
	if [ $# -lt 4 ]; then
		prn_dbg "(dbaas_get_openstack_launch_post_data) Parameter wrong."
		pecho -n ""
		return 1
	fi
	if [ "X$1" = "X" ] || [ "X$2" = "X" ] || [ "X$3" = "X" ] || [ "X$4" = "X" ]; then
		prn_dbg "(dbaas_get_openstack_launch_post_data) Parameters($1, $2, $3, $4) wrong."
		pecho -n ""
		return 1
	fi
	_DBAAS_LAUNCH_DATA_SERVER_NAME=$1
	_DBAAS_LAUNCH_DATA_IMAGE_ID=$2
	_DBAAS_LAUNCH_DATA_FLAVOR_ID=$3
	_DBAAS_LAUNCH_DATA_USERDATA=$4
	if [ "X$5" = "X" ]; then
		_DBAAS_LAUNCH_DATA_KEYPAIR=""
	else
		_DBAAS_LAUNCH_DATA_KEYPAIR=$5
	fi
	if [ "X$6" = "X" ]; then
		_DBAAS_LAUNCH_DATA_SECGRP=""
	else
		_DBAAS_LAUNCH_DATA_SECGRP=$6
	fi

	#
	# Check template file
	#
	_DATABASE_CREATE_HOST_FILE=""
	if [ "X${K2HR3CLI_DBAAS_CONFIG}" != "X" ]; then
		#
		# Specified custom dbaas configuration directory
		#
		if [ -d "${K2HR3CLI_DBAAS_CONFIG}" ]; then
			if [ -f "${K2HR3CLI_DBAAS_CONFIG}/${_DATABASE_DEFAULT_CREATE_HOST_FILENAME}" ]; then
				_DATABASE_CREATE_HOST_FILE="${K2HR3CLI_DBAAS_CONFIG}/${_DATABASE_DEFAULT_CREATE_HOST_FILENAME}"
			else
				prn_err "Specified K2HDKC DBaaS CLI Configuration(${K2HR3CLI_DBAAS_CONFIG}/${_DATABASE_DEFAULT_CREATE_HOST_FILENAME}) is not existed."
				pecho -n ""
				return 1
			fi
		else
			prn_err "Specified K2HDKC DBaaS CLI Configuration directory(${K2HR3CLI_DBAAS_CONFIG}) is not existed."
			pecho -n ""
			return 1
		fi
	else
		#
		# Check user home dbaas configuration
		#
		_DATABASE_USER_CONFIG_DIR=$(config_get_default_user_dir)
		if [ -d "${_DATABASE_USER_CONFIG_DIR}" ]; then
			if [ -f "${_DATABASE_USER_CONFIG_DIR}/${_DATABASE_DEFAULT_CREATE_HOST_FILENAME}" ]; then
				_DATABASE_CREATE_HOST_FILE="${_DATABASE_USER_CONFIG_DIR}/${_DATABASE_DEFAULT_CREATE_HOST_FILENAME}"
			fi
		fi

		if [ "X${_DATABASE_CREATE_HOST_FILE}" = "X" ]; then
			#
			# Default dbaas configuration
			#
			if [ -d "${_DATABASE_CURRENT_DIR}" ]; then
				if [ -f "${_DATABASE_CURRENT_DIR}/${_DATABASE_DEFAULT_CREATE_HOST_FILENAME}" ]; then
					_DATABASE_CREATE_HOST_FILE="${_DATABASE_CURRENT_DIR}/${_DATABASE_DEFAULT_CREATE_HOST_FILENAME}"
				else
					prn_warn "Default K2HDKC DBaaS CLI Configuration(${_DATABASE_CURRENT_DIR}/${_DATABASE_DEFAULT_CREATE_HOST_FILENAME}) is not existed."
				fi
			else
				prn_warn "Default K2HDKC DBaaS CLI Directory(${_DATABASE_CURRENT_DIR}) is not existed."
			fi
		fi
	fi

	#
	# Load template file to string
	#
	_DATABASE_CREATE_HOST_DATA=$(sed -e 's/#.*$//g' -e 's/^[[:space:]]\+//g' -e 's/[[:space:]]\+$//g' "${_DATABASE_CREATE_HOST_FILE}" | tr -d '\n')
	if [ $? -ne 0 ]; then
		prn_err "Could load the template file for launching host."
		pecho -n ""
		return 1
	fi

	#
	# Replace keyword
	#
	if [ "X${_DBAAS_LAUNCH_DATA_SECGRP}" != "X" ]; then
		#
		# Set Security Group
		#	"security_groups": [
		#		{
		#			"name":"default"
		#		},
		#		{
		#			"name":"<...security group...>"
		#		}
		#	],
		#
		_DBAAS_LAUNCH_DATA_SECGRP="\"security_groups\":[{\"name\":\"default\"},{\"name\":\"${_DBAAS_LAUNCH_DATA_SECGRP}\"}],"
	fi
	if [ "X${_DBAAS_LAUNCH_DATA_KEYPAIR}" != "X" ]; then
		#
		# Set Keypair
		#	"key_name":"<...name...>",
		#
		_DBAAS_LAUNCH_DATA_KEYPAIR="\"key_name\":\"${_DBAAS_LAUNCH_DATA_KEYPAIR}\","
	fi

	_DATABASE_CREATE_HOST_DATA=$(pecho -n "${_DATABASE_CREATE_HOST_DATA}" | sed \
			-e "s|__K2HDKC_DBAAS_LAUNCH_VM_TEMPLATE_SECGRP_SET__|${_DBAAS_LAUNCH_DATA_SECGRP}|" \
			-e "s|__K2HDKC_DBAAS_LAUNCH_VM_TEMPLATE_KEYPAIR_SET__|${_DBAAS_LAUNCH_DATA_KEYPAIR}|" \
			-e "s|__K2HDKC_DBAAS_LAUNCH_VM_TEMPLATE_SERVER_NAME__|${_DBAAS_LAUNCH_DATA_SERVER_NAME}|" \
			-e "s|__K2HDKC_DBAAS_LAUNCH_VM_TEMPLATE_IMAGE_ID__|${_DBAAS_LAUNCH_DATA_IMAGE_ID}|" \
			-e "s|__K2HDKC_DBAAS_LAUNCH_VM_TEMPLATE_FLAVOR_ID__|${_DBAAS_LAUNCH_DATA_FLAVOR_ID}|" \
			-e "s|__K2HDKC_DBAAS_LAUNCH_VM_TEMPLATE_USER_DATA__|${_DBAAS_LAUNCH_DATA_USERDATA}|")

	if [ "X${_DATABASE_CREATE_HOST_DATA}" = "X" ]; then
		prn_err "Could load the template file for launching host."
		pecho -n ""
		return 1
	fi

	pecho -n "${_DATABASE_CREATE_HOST_DATA}"

	return 0
}

#
# Parse one k2hr3 host information
#
# $1	: one host information(space separator)
# $?	: result
#
# Output Variables
#	DATABASE_PARSE_K2HR3_HOSTNAME	: first part
#	DATABASE_PARSE_K2HR3_PORT		: 2'nd part
#	DATABASE_PARSE_K2HR3_CUK		: 3'rd part
#	DATABASE_PARSE_K2HR3_EXTRA		: 4'th part
#	DATABASE_PARSE_K2HR3_TAG		: last part
#
dbaas_parse_k2hr3_host_info()
{
	DATABASE_PARSE_K2HR3_HOSTNAME=""
	DATABASE_PARSE_K2HR3_PORT=0
	DATABASE_PARSE_K2HR3_CUK=""
	DATABASE_PARSE_K2HR3_EXTRA=""
	DATABASE_PARSE_K2HR3_TAG=""

	_DATABASE_PARSE_K2HR3_REMAINING="$1"

	#
	# First part(hostname or ip address)
	#
	DATABASE_PARSE_K2HR3_HOSTNAME=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | awk '{print $1}')
	_DATABASE_TMP_NEXT_POS=$((${#DATABASE_PARSE_K2HR3_HOSTNAME} + 2))
	_DATABASE_PARSE_K2HR3_REMAINING=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -c "${_DATABASE_TMP_NEXT_POS}"-)

	#
	# 2'nd part
	#
	_DATABASE_PARSE_K2HR3_CHAR=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -b 1)
	if [ "X${_DATABASE_PARSE_K2HR3_CHAR}" = "X" ];then
		#
		# No more data
		#
		return 0
	fi
	if [ "X${_DATABASE_PARSE_K2HR3_CHAR}" != "X " ]; then
		#
		# 2'nd part is existed
		#
		DATABASE_PARSE_K2HR3_PORT=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | awk '{print $1}')

		#
		# Next
		#
		_DATABASE_TMP_NEXT_POS=$((${#DATABASE_PARSE_K2HR3_PORT} + 2))
		_DATABASE_PARSE_K2HR3_REMAINING=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -c "${_DATABASE_TMP_NEXT_POS}"-)

		if [ "X${DATABASE_PARSE_K2HR3_PORT}" = "X" ] || [ "X${DATABASE_PARSE_K2HR3_PORT}" = "X*" ]; then
			DATABASE_PARSE_K2HR3_PORT=0
		fi
	else
		_DATABASE_PARSE_K2HR3_REMAINING=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -c 2-)
	fi

	#
	# 3'rd part
	#
	_DATABASE_PARSE_K2HR3_CHAR=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -b 1)
	if [ "X${_DATABASE_PARSE_K2HR3_CHAR}" = "X" ];then
		#
		# No more data
		#
		return 0
	fi
	if [ "X${_DATABASE_PARSE_K2HR3_CHAR}" != "X " ]; then
		#
		# 3'rd part is existed
		#
		DATABASE_PARSE_K2HR3_CUK=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | awk '{print $1}')

		#
		# Next
		#
		_DATABASE_TMP_NEXT_POS=$((${#DATABASE_PARSE_K2HR3_CUK} + 2))
		_DATABASE_PARSE_K2HR3_REMAINING=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -c "${_DATABASE_TMP_NEXT_POS}"-)
	else
		_DATABASE_PARSE_K2HR3_REMAINING=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -c 2-)
	fi

	#
	# 4'th part
	#
	_DATABASE_PARSE_K2HR3_CHAR=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -b 1)
	if [ "X${_DATABASE_PARSE_K2HR3_CHAR}" = "X" ];then
		#
		# No more data
		#
		return 0
	fi
	if [ "X${_DATABASE_PARSE_K2HR3_CHAR}" != "X " ]; then
		#
		# 4'th part is existed
		#
		DATABASE_PARSE_K2HR3_EXTRA=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | awk '{print $1}')

		#
		# Next
		#
		_DATABASE_TMP_NEXT_POS=$((${#DATABASE_PARSE_K2HR3_EXTRA} + 2))
		_DATABASE_PARSE_K2HR3_REMAINING=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -c "${_DATABASE_TMP_NEXT_POS}"-)
	else
		_DATABASE_PARSE_K2HR3_REMAINING=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -c 2-)
	fi

	#
	# Last part
	#
	_DATABASE_PARSE_K2HR3_CHAR=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -b 1)
	if [ "X${_DATABASE_PARSE_K2HR3_CHAR}" = "X" ];then
		#
		# No more data
		#
		return 0
	fi
	if [ "X${_DATABASE_PARSE_K2HR3_CHAR}" != "X " ]; then
		#
		# Last part is existed
		#
		DATABASE_PARSE_K2HR3_TAG=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | awk '{print $1}')

		#
		# Next
		#
		_DATABASE_TMP_NEXT_POS=$((${#DATABASE_PARSE_K2HR3_TAG} + 2))
		_DATABASE_PARSE_K2HR3_REMAINING=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -c "${_DATABASE_TMP_NEXT_POS}"-)
	else
		_DATABASE_PARSE_K2HR3_REMAINING=$(pecho -n "${_DATABASE_PARSE_K2HR3_REMAINING}" | cut -c 2-)
	fi

	return 0
}

#
# Search host in role
#
# $1							: role path
# $2							: host
# $?							: result
# Output
#	DBAAS_FIND_ROLE_HOST_NAME	: hostname or ip
#	DBAAS_FIND_ROLE_HOST_PORT	: port(* to 0)
#	DBAAS_FIND_ROLE_HOST_CUK	: cuk
#
dbaas_find_role_host()
{
	# shellcheck disable=SC2034
	DBAAS_FIND_ROLE_HOST_NAME=""
	# shellcheck disable=SC2034
	DBAAS_FIND_ROLE_HOST_PORT=0
	# shellcheck disable=SC2034
	DBAAS_FIND_ROLE_HOST_CUK=""

	if [ "X$1" = "X" ] || [  "X$2" = "X" ]; then
		prn_dbg "(dbaas_find_role_host) Parameter is wrong."
		return 1
	fi
	_DBAAS_DEL_ROLE_PATH=$1

	#
	# Get host list(run k2hr3)
	#
	# [MEMO]
	#	Host is "<hostname or ip> <port> <cuk> <extra> <tag>"
	#	{
	#		"policies": [],
	#		"aliases": [],
	#		"hosts": {
	#			"hostnames": [
	#				"hostname * xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx openstack-auto-v1 localhostname"
	#			],
	#			"ips": [
	#				"10.0.0.1 * xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx openstack-auto-v1 localhostname"
	#			]
	#		}
	#	}
	#
	_DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" role show "${_DBAAS_DEL_ROLE_PATH}")

	#
	# Parse
	#
	jsonparser_parse_json_string "${_DATABASE_RESULT}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_find_role_host) Failed to parse host list."
		return 1
	fi

	#
	# Search in hosts->hostnames
	#
	jsonparser_get_key_value '%"hosts"%"hostnames"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_find_role_host) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->hostnames, thus skip this role."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DATABASE_RESULT_HOSTNAME_LIST=${JSONPARSER_FIND_KEY_VAL}

	#
	# Loop hostnames
	#
	for _DATABASE_RESULT_HOSTNAME_POS in ${_DATABASE_RESULT_HOSTNAME_LIST}; do
		_DATABASE_RESULT_HOSTNAME_POS_RAW=$(pecho -n "${_DATABASE_RESULT_HOSTNAME_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"hosts\"%\"hostnames\"%${_DATABASE_RESULT_HOSTNAME_POS_RAW}%" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(dbaas_find_role_host) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->hostnames[${_DATABASE_RESULT_HOSTNAME_POS_RAW}], thus skip this role."
			continue
		fi

		dbaas_parse_k2hr3_host_info "${JSONPARSER_FIND_STR_VAL}"
		if [ "X${DATABASE_PARSE_K2HR3_HOSTNAME}" = "X$2" ] || [ "X${DATABASE_PARSE_K2HR3_TAG}" = "X$2" ]; then
			#
			# Found (The TAG may have a hostname and the HOSTNAME may be an IP address)
			#
			# shellcheck disable=SC2034
			DBAAS_FIND_ROLE_HOST_NAME=${DATABASE_PARSE_K2HR3_HOSTNAME}
			# shellcheck disable=SC2034
			DBAAS_FIND_ROLE_HOST_PORT=${DATABASE_PARSE_K2HR3_PORT}
			# shellcheck disable=SC2034
			DBAAS_FIND_ROLE_HOST_CUK=${DATABASE_PARSE_K2HR3_CUK}
			return 0
		fi
	done

	#
	# Search in hosts->ips
	#
	jsonparser_get_key_value '%"hosts"%"ips"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_find_role_host) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->ips, thus skip this role."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	_DATABASE_RESULT_IP_LIST=${JSONPARSER_FIND_KEY_VAL}

	#
	# Loop ips
	#
	for _DATABASE_RESULT_IP_POS in ${_DATABASE_RESULT_IP_LIST}; do
		_DATABASE_RESULT_IP_POS_RAW=$(pecho -n "${_DATABASE_RESULT_IP_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"hosts\"%\"ips\"%${_DATABASE_RESULT_IP_POS_RAW}%" "${JP_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(dbaas_find_role_host) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->ips[${_DATABASE_RESULT_IP_POS_RAW}], thus skip this role."
			continue
		fi

		dbaas_parse_k2hr3_host_info "${JSONPARSER_FIND_STR_VAL}"
		if [ "X${DATABASE_PARSE_K2HR3_HOSTNAME}" = "X$2" ] || [ "X${DATABASE_PARSE_K2HR3_TAG}" = "X$2" ]; then
			#
			# Found (The TAG may have a hostname and the HOSTNAME may be an IP address)
			#
			# shellcheck disable=SC2034
			DBAAS_FIND_ROLE_HOST_NAME=${DATABASE_PARSE_K2HR3_HOSTNAME}
			# shellcheck disable=SC2034
			DBAAS_FIND_ROLE_HOST_PORT=${DATABASE_PARSE_K2HR3_PORT}
			# shellcheck disable=SC2034
			DBAAS_FIND_ROLE_HOST_CUK=${DATABASE_PARSE_K2HR3_CUK}
			return 0
		fi
	done

	rm -f "${JP_PAERSED_FILE}"

	return 1
}

#
# show all hosts
#
# $1	: json parsed file
# $?	: result
#
# Output Variables
#	DATABSE_HOST_LIST
#
dbaas_show_all_hosts()
{
	if [ "X$1" = "X" ]; then
		return 1
	fi
	if [ ! -f "$1" ]; then
		return 1
	fi
	_DATABASE_HOST_PAERSED_FILE=$1
	_DATABSE_HOST_ISSET=0
	DATABSE_HOST_LIST="["

	#
	# "hostnames" key
	#
	jsonparser_get_key_value '%"hosts"%"hostnames"%' "${_DATABASE_HOST_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "(dbaas_show_all_hosts) The result \"hosts\" key does not have \"hostnames\" element."
	else
		if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_ARR}" ]; then
			prn_warn "(dbaas_show_all_hosts) The result \"hosts\"->\"hostnames\" key is not array."
		else
			_DATABASE_HOST_HOSTNAMES=${JSONPARSER_FIND_KEY_VAL}
			for _DATABASE_HOST_HOSTNAME_POS in ${_DATABASE_HOST_HOSTNAMES}; do
				_DATABASE_HOST_HOSTNAME_POS_RAW=$(pecho -n "${_DATABASE_HOST_HOSTNAME_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
				jsonparser_get_key_value "%\"hosts\"%\"hostnames\"%${_DATABASE_HOST_HOSTNAME_POS_RAW}%" "${_DATABASE_HOST_PAERSED_FILE}"
				if [ $? -ne 0 ]; then
					prn_warn "(dbaas_show_all_hosts) The result \"hosts\"->\"hostnames[${_DATABASE_HOST_HOSTNAME_POS_RAW}]\" is not found."
					continue
				fi
				if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_STR}" ]; then
					prn_warn "(dbaas_show_all_hosts) The result \"hosts\"->\"hostnames[${_DATABASE_HOST_HOSTNAME_POS_RAW}]\" is not string type."
					continue
				fi
				#
				# Parse host information
				#
				dbaas_parse_k2hr3_host_info "${JSONPARSER_FIND_STR_VAL}"
				if [ "X${DATABASE_PARSE_K2HR3_HOSTNAME}" = "X" ]; then
					prn_warn "(dbaas_show_all_hosts) The result \"hosts\"->\"hostnames[${_DATABASE_HOST_HOSTNAME_POS_RAW}]\" is something wrong."
					continue
				fi
				_DATABSE_HOST_ONE_HOST="{\"name\":\"${DATABASE_PARSE_K2HR3_TAG}\",\"id\":\"${DATABASE_PARSE_K2HR3_CUK}\",\"hostname\":\"${DATABASE_PARSE_K2HR3_HOSTNAME}\"}"

				if [ "${_DATABSE_HOST_ISSET}" -eq 0 ]; then
					DATABSE_HOST_LIST="${DATABSE_HOST_LIST}${_DATABSE_HOST_ONE_HOST}"
				else
					DATABSE_HOST_LIST="${DATABSE_HOST_LIST},${_DATABSE_HOST_ONE_HOST}"
				fi
			done
		fi
	fi


	#
	# "ips" key
	#
	jsonparser_get_key_value '%"hosts"%"ips"%' "${_DATABASE_HOST_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_warn "(dbaas_show_all_hosts) The result \"hosts\" key does not have \"ips\" element."
	else
		if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_ARR}" ]; then
			prn_warn "(dbaas_show_all_hosts) The result \"hosts\"->\"ips\" key is not array."
		else
			_DATABASE_HOST_IPS=${JSONPARSER_FIND_KEY_VAL}
			for _DATABASE_HOST_IPS_POS in ${_DATABASE_HOST_IPS}; do
				_DATABASE_HOST_IPS_POS_RAW=$(pecho -n "${_DATABASE_HOST_IPS_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
				jsonparser_get_key_value "%\"hosts\"%\"ips\"%${_DATABASE_HOST_IPS_POS_RAW}%" "${_DATABASE_HOST_PAERSED_FILE}"
				if [ $? -ne 0 ]; then
					prn_warn "(dbaas_show_all_hosts) The result \"hosts\"->\"ips[${_DATABASE_HOST_HOSTNAME_POS_RAW}]\" is not found."
					continue
				fi
				if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_STR}" ]; then
					prn_warn "(dbaas_show_all_hosts) The result \"hosts\"->\"ips[${_DATABASE_HOST_HOSTNAME_POS_RAW}]\" is not string type."
					continue
				fi
				#
				# Parse host information
				#
				dbaas_parse_k2hr3_host_info "${JSONPARSER_FIND_STR_VAL}"
				if [ "X${DATABASE_PARSE_K2HR3_HOSTNAME}" = "X" ]; then
					prn_warn "(dbaas_show_all_hosts) The result \"hosts\"->\"hostnames[${_DATABASE_HOST_HOSTNAME_POS_RAW}]\" is something wrong."
					continue
				fi
				_DATABSE_HOST_ONE_HOST="{\"name\":\"${DATABASE_PARSE_K2HR3_TAG}\",\"id\":\"${DATABASE_PARSE_K2HR3_CUK}\",\"ip\":\"${DATABASE_PARSE_K2HR3_HOSTNAME}\"}"

				if [ "${_DATABSE_HOST_ISSET}" -eq 0 ]; then
					DATABSE_HOST_LIST="${DATABSE_HOST_LIST}${_DATABSE_HOST_ONE_HOST}"
				else
					DATABSE_HOST_LIST="${DATABSE_HOST_LIST},${_DATABSE_HOST_ONE_HOST}"
				fi
			done
		fi
	fi

	DATABSE_HOST_LIST="${DATABSE_HOST_LIST}]"
	return 0
}

#
# Delete host in role
#
# $1							: role path
# $2							: host name
# $3							: port
# $4							: cuk
# $?							: result
#
dbaas_delete_role_host()
{
	if [ "X$1" = "X" ] || [ "X$2" = "X" ]; then
		prn_dbg "(dbaas_delete_role_host) Parameter is wrong."
		return 1
	fi
	_DBAAS_DEL_ROLE_PATH=$1
	_DBAAS_DEL_ROLE_HOST_NAME=$2

	if [ "X$3" != "X" ]; then
		_DBAAS_DEL_ROLE_HOST_PORT=$3
	else
		_DBAAS_DEL_ROLE_HOST_PORT=0
	fi

	if [ "X$4" != "X" ]; then
		_DBAAS_DEL_ROLE_HOST_CUK=$4
		_DBAAS_DEL_ROLE_HOST_CUK_OPT="--cuk"
	else
		_DBAAS_DEL_ROLE_HOST_CUK=""
		_DBAAS_DEL_ROLE_HOST_CUK_OPT=""
	fi

	#
	# Delete host from role(Run k2hr3)
	#
	_DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" role host delete "${_DBAAS_DEL_ROLE_PATH}" --host "${_DBAAS_DEL_ROLE_HOST_NAME}" --port "${_DBAAS_DEL_ROLE_HOST_PORT}" "${_DBAAS_DEL_ROLE_HOST_CUK_OPT}" "${_DBAAS_DEL_ROLE_HOST_CUK}")

	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_role_host) Failed to delete ${_DBAAS_DEL_ROLE_HOST_NAME} from ${_DBAAS_DEL_ROLE_PATH} role : ${_DATABASE_RESULT}"
		return 1
	fi

	prn_dbg "(dbaas_delete_role_host) Deleted host ${_DBAAS_DEL_ROLE_HOST_NAME} from ${_DBAAS_DEL_ROLE_PATH} role."
	return 0
}

#
# delete all host in role/openstack
#
# $1	: root role path
# $?	: result
#
# [NOTE]
#	This function calls openstack function.
#
dbaas_delete_role_host_all()
{
	if [ "X$1" = "X" ]; then
		prn_dbg "(dbaas_delete_role_host_all) Parameter is wrong."
		return 1
	fi
	_DBAAS_DELALL_ROLE_PATH=$1

	#------------------------------------------------------
	# Loop server host list(run k2hr3)
	#------------------------------------------------------
	# [MEMO]
	#	Host is "<hostname or ip> <port> <cuk> <extra> <tag>"
	#	{
	#		"policies": [],
	#		"aliases": [],
	#		"hosts": {
	#			"hostnames": [
	#				"hostname * xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx openstack-auto-v1 localhostname"
	#			],
	#			"ips": [
	#				"10.0.0.1 * xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx openstack-auto-v1 localhostname"
	#			]
	#		}
	#	}
	#
	_DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" role show "${_DBAAS_DELALL_ROLE_PATH}/server")

	#
	# Parse
	#
	jsonparser_parse_json_string "${_DATABASE_RESULT}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_role_host_all) Failed to parse result."
		return 1
	fi
	_DATABASE_HOSTS_PAERSED_FILE=${JP_PAERSED_FILE}

	#
	# Search in server hosts->hostnames
	#
	jsonparser_get_key_value '%"hosts"%"hostnames"%' "${_DATABASE_HOSTS_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_role_host_all) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->hostnames, thus skip this role."
		rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
		return 1
	fi
	_DATABASE_RESULT_HOSTNAME_LIST=${JSONPARSER_FIND_KEY_VAL}

	#
	# Loop server hosts->hostnames
	#
	for _DATABASE_RESULT_HOSTNAME_POS in ${_DATABASE_RESULT_HOSTNAME_LIST}; do
		_DATABASE_RESULT_HOSTNAME_POS_RAW=$(pecho -n "${_DATABASE_RESULT_HOSTNAME_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"hosts\"%\"hostnames\"%${_DATABASE_RESULT_HOSTNAME_POS_RAW}%" "${_DATABASE_HOSTS_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(dbaas_delete_role_host_all) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->hostnames[${_DATABASE_RESULT_HOSTNAME_POS_RAW}], thus skip this role."
			continue
		fi

		dbaas_parse_k2hr3_host_info "${JSONPARSER_FIND_STR_VAL}"
		_DATABASE_TMP_ROLE_HOST_NAME=${DATABASE_PARSE_K2HR3_HOSTNAME}
		_DATABASE_TMP_ROLE_HOST_PORT=${DATABASE_PARSE_K2HR3_PORT}
		_DATABASE_TMP_ROLE_HOST_CUK=${DATABASE_PARSE_K2HR3_CUK}

		#
		# Delete host from openstack
		#
		if [ "X${_DATABASE_TMP_ROLE_HOST_CUK}" != "X" ]; then
			delete_op_host "${_DATABASE_TMP_ROLE_HOST_CUK}"
			if [ $? -ne 0 ]; then
				prn_err "Failed to delete ${_DATABASE_TMP_ROLE_HOST_NAME} from OpenStack."
				rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
				return 1
			fi
		else
			prn_dbg "Found ${_DATABASE_TMP_ROLE_HOST_NAME} host in ${_DBAAS_DELALL_ROLE_PATH}/server role, but it does not have Host id for opensteck."
		fi

		#
		# Delete host from k2hr3
		#
		dbaas_delete_role_host "${_DBAAS_DELALL_ROLE_PATH}/server" "${_DATABASE_TMP_ROLE_HOST_NAME}" "${_DATABASE_TMP_ROLE_HOST_PORT}" "${_DATABASE_TMP_ROLE_HOST_CUK}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to delete ${_DATABASE_TMP_ROLE_HOST_NAME} from ${_DBAAS_DELALL_ROLE_PATH}/server role"
			rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
			return 1
		fi
	done

	#
	# Search in server hosts->ips
	#
	jsonparser_get_key_value '%"hosts"%"ips"%' "${_DATABASE_HOSTS_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_role_host_all) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->ips, thus skip this role."
		rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
		return 1
	fi
	_DATABASE_RESULT_HOSTNAME_LIST=${JSONPARSER_FIND_KEY_VAL}

	#
	# Loop server hosts->ips
	#
	for _DATABASE_RESULT_HOSTNAME_POS in ${_DATABASE_RESULT_HOSTNAME_LIST}; do
		_DATABASE_RESULT_HOSTNAME_POS_RAW=$(pecho -n "${_DATABASE_RESULT_HOSTNAME_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"hosts\"%\"ips\"%${_DATABASE_RESULT_HOSTNAME_POS_RAW}%" "${_DATABASE_HOSTS_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(dbaas_delete_role_host_all) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->ips[${_DATABASE_RESULT_HOSTNAME_POS_RAW}], thus skip this role."
			continue
		fi

		dbaas_parse_k2hr3_host_info "${JSONPARSER_FIND_STR_VAL}"
		_DATABASE_TMP_ROLE_HOST_NAME=${DATABASE_PARSE_K2HR3_HOSTNAME}
		_DATABASE_TMP_ROLE_HOST_PORT=${DATABASE_PARSE_K2HR3_PORT}
		_DATABASE_TMP_ROLE_HOST_CUK=${DATABASE_PARSE_K2HR3_CUK}

		#
		# Delete host from openstack
		#
		if [ "X${_DATABASE_TMP_ROLE_HOST_CUK}" != "X" ]; then
			delete_op_host "${_DATABASE_TMP_ROLE_HOST_CUK}"
			if [ $? -ne 0 ]; then
				prn_err "Failed to delete ${_DATABASE_TMP_ROLE_HOST_NAME} from OpenStack."
				rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
				return 1
			fi
		else
			prn_dbg "Found ${_DATABASE_TMP_ROLE_HOST_NAME} host in ${_DBAAS_DELALL_ROLE_PATH}/server role, but it does not have Host id for opensteck."
		fi

		#
		# Delete host from k2hr3
		#
		dbaas_delete_role_host "${_DBAAS_DELALL_ROLE_PATH}/server" "${_DATABASE_TMP_ROLE_HOST_NAME}" "${_DATABASE_TMP_ROLE_HOST_PORT}" "${_DATABASE_TMP_ROLE_HOST_CUK}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to delete ${_DATABASE_TMP_ROLE_HOST_NAME} from ${_DBAAS_DELALL_ROLE_PATH}/server role"
			rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
			return 1
		fi
	done
	rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"

	#------------------------------------------------------
	# Loop slave host list(run k2hr3)
	#------------------------------------------------------
	_DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" role show "${_DBAAS_DELALL_ROLE_PATH}/slave")

	#
	# Parse
	#
	jsonparser_parse_json_string "${_DATABASE_RESULT}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_role_host_all) Failed to parse result."
		return 1
	fi
	_DATABASE_HOSTS_PAERSED_FILE=${JP_PAERSED_FILE}

	#
	# Search in slave hosts->hostnames
	#
	jsonparser_get_key_value '%"hosts"%"hostnames"%' "${_DATABASE_HOSTS_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_role_host_all) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->hostnames, thus skip this role."
		rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
		return 1
	fi
	_DATABASE_RESULT_HOSTNAME_LIST=${JSONPARSER_FIND_KEY_VAL}

	#
	# Loop slave hosts->hostnames
	#
	for _DATABASE_RESULT_HOSTNAME_POS in ${_DATABASE_RESULT_HOSTNAME_LIST}; do
		_DATABASE_RESULT_HOSTNAME_POS_RAW=$(pecho -n "${_DATABASE_RESULT_HOSTNAME_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"hosts\"%\"hostnames\"%${_DATABASE_RESULT_HOSTNAME_POS_RAW}%" "${_DATABASE_HOSTS_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(dbaas_delete_role_host_all) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->hostnames[${_DATABASE_RESULT_HOSTNAME_POS_RAW}], thus skip this role."
			continue
		fi

		dbaas_parse_k2hr3_host_info "${JSONPARSER_FIND_STR_VAL}"
		_DATABASE_TMP_ROLE_HOST_NAME=${DATABASE_PARSE_K2HR3_HOSTNAME}
		_DATABASE_TMP_ROLE_HOST_PORT=${DATABASE_PARSE_K2HR3_PORT}
		_DATABASE_TMP_ROLE_HOST_CUK=${DATABASE_PARSE_K2HR3_CUK}

		#
		# Delete host from openstack
		#
		if [ "X${_DATABASE_TMP_ROLE_HOST_CUK}" != "X" ]; then
			delete_op_host "${_DATABASE_TMP_ROLE_HOST_CUK}"
			if [ $? -ne 0 ]; then
				prn_err "Failed to delete ${_DATABASE_TMP_ROLE_HOST_NAME} from OpenStack."
				rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
				return 1
			fi
		else
			prn_dbg "Found ${_DATABASE_TMP_ROLE_HOST_NAME} host in ${_DBAAS_DELALL_ROLE_PATH}/slave role, but it does not have Host id for opensteck."
		fi

		#
		# Delete host from k2hr3
		#
		dbaas_delete_role_host "${_DBAAS_DELALL_ROLE_PATH}/slave" "${_DATABASE_TMP_ROLE_HOST_NAME}" "${_DATABASE_TMP_ROLE_HOST_PORT}" "${_DATABASE_TMP_ROLE_HOST_CUK}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to delete ${_DATABASE_TMP_ROLE_HOST_NAME} from ${_DBAAS_DELALL_ROLE_PATH}/slave role"
			rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
			return 1
		fi
	done

	#
	# Search in slave hosts->ips
	#
	jsonparser_get_key_value '%"hosts"%"ips"%' "${_DATABASE_HOSTS_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_role_host_all) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->ips, thus skip this role."
		rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
		return 1
	fi
	_DATABASE_RESULT_HOSTNAME_LIST=${JSONPARSER_FIND_KEY_VAL}

	#
	# Loop slave hosts->ips
	#
	for _DATABASE_RESULT_HOSTNAME_POS in ${_DATABASE_RESULT_HOSTNAME_LIST}; do
		_DATABASE_RESULT_HOSTNAME_POS_RAW=$(pecho -n "${_DATABASE_RESULT_HOSTNAME_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
		jsonparser_get_key_value "%\"hosts\"%\"ips\"%${_DATABASE_RESULT_HOSTNAME_POS_RAW}%" "${_DATABASE_HOSTS_PAERSED_FILE}"
		if [ $? -ne 0 ]; then
			prn_dbg "(dbaas_delete_role_host_all) Failed to get ${_DBAAS_DEL_ROLE_PATH} hosts->ips[${_DATABASE_RESULT_HOSTNAME_POS_RAW}], thus skip this role."
			continue
		fi

		dbaas_parse_k2hr3_host_info "${JSONPARSER_FIND_STR_VAL}"
		_DATABASE_TMP_ROLE_HOST_NAME=${DATABASE_PARSE_K2HR3_HOSTNAME}
		_DATABASE_TMP_ROLE_HOST_PORT=${DATABASE_PARSE_K2HR3_PORT}
		_DATABASE_TMP_ROLE_HOST_CUK=${DATABASE_PARSE_K2HR3_CUK}

		#
		# Delete host from openstack
		#
		if [ "X${_DATABASE_TMP_ROLE_HOST_CUK}" != "X" ]; then
			delete_op_host "${_DATABASE_TMP_ROLE_HOST_CUK}"
			if [ $? -ne 0 ]; then
				prn_err "Failed to delete ${_DATABASE_TMP_ROLE_HOST_NAME} from OpenStack."
				rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
				return 1
			fi
		else
			prn_dbg "Found ${_DATABASE_TMP_ROLE_HOST_NAME} host in ${_DBAAS_DELALL_ROLE_PATH}/slave role, but it does not have Host id for opensteck."
		fi

		#
		# Delete host from k2hr3
		#
		dbaas_delete_role_host "${_DBAAS_DELALL_ROLE_PATH}/slave" "${_DATABASE_TMP_ROLE_HOST_NAME}" "${_DATABASE_TMP_ROLE_HOST_PORT}" "${_DATABASE_TMP_ROLE_HOST_CUK}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to delete ${_DATABASE_TMP_ROLE_HOST_NAME} from ${_DBAAS_DELALL_ROLE_PATH}/slave role"
			rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"
			return 1
		fi
	done
	rm -f "${_DATABASE_HOSTS_PAERSED_FILE}"

	return 0
}

#
# delete all role/policy/resource
#
# $1	: root role path
# $?	: result
#
dbaas_delete_all_k2hr3()
{
	if [ "X$1" = "X" ]; then
		prn_dbg "(dbaas_delete_all_k2hr3) Parameter is wrong."
		return 1
	fi
	_DBAAS_DEL_CLUSTER_NAME=$1
	_DBAAS_DEL_CLUSTER_SERVER="${_DBAAS_DEL_CLUSTER_NAME}/server"
	_DBAAS_DEL_CLUSTER_SLAVE="${_DBAAS_DEL_CLUSTER_NAME}/slave"

	#
	# Delete Slave Role
	#
	_DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" role delete "${_DBAAS_DEL_CLUSTER_SLAVE}")
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_all_k2hr3) Failed to delete ${_DBAAS_DEL_CLUSTER_SLAVE} role : ${_DATABASE_RESULT}"
		return 1
	fi

	#
	# Delete Server Role
	#
	_DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" role delete "${_DBAAS_DEL_CLUSTER_SERVER}")
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_all_k2hr3) Failed to delete ${_DBAAS_DEL_CLUSTER_SERVER} role : ${_DATABASE_RESULT}"
		return 1
	fi

	#
	# Delete Top Role
	#
	_DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" role delete "${_DBAAS_DEL_CLUSTER_NAME}")
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_all_k2hr3) Failed to delete ${_DBAAS_DEL_CLUSTER_NAME} role : ${_DATABASE_RESULT}"
		return 1
	fi

	#
	# Delete Policy
	#
	_DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" policy delete "${_DBAAS_DEL_CLUSTER_NAME}")
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_all_k2hr3) Failed to delete ${_DBAAS_DEL_CLUSTER_NAME} policy : ${_DATABASE_RESULT}"
		return 1
	fi

	#
	# Delete Slave Resource
	#
	_DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" resource delete "${_DBAAS_DEL_CLUSTER_SLAVE}")
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_all_k2hr3) Failed to delete ${_DBAAS_DEL_CLUSTER_SLAVE} resource : ${_DATABASE_RESULT}"
		return 1
	fi

	#
	# Delete Server Resource
	#
	_DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" resource delete "${_DBAAS_DEL_CLUSTER_SERVER}")
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_all_k2hr3) Failed to delete ${_DBAAS_DEL_CLUSTER_SERVER} resource : ${_DATABASE_RESULT}"
		return 1
	fi

	#
	# Delete Top Resource
	#
	_DATABASE_RESULT=$(K2HR3CLI_API_URI="${K2HR3CLI_API_URI}" K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}" K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}" K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}" K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}" K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}" K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" \
	"${K2HR3CLIBIN}" resource delete "${_DBAAS_DEL_CLUSTER_NAME}")
	if [ $? -ne 0 ]; then
		prn_dbg "(dbaas_delete_all_k2hr3) Failed to delete ${_DBAAS_DEL_CLUSTER_NAME} resource : ${_DATABASE_RESULT}"
		return 1
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
