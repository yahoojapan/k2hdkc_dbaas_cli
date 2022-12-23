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
# [NOTE]
# This file is loaded from the test script or from the k2hr3 process.
# So create the exact path to the test directory here.
#
_INIT_TESTDIR=$(dirname "$0")
TESTDIR=$(cd "${_INIT_TESTDIR}/../test" || exit 1; pwd)

#
# Set own file path to K2HR3CLI_REQUEST_FILE if it is empty
#
if [ -z "${K2HR3CLI_REQUEST_FILE}" ]; then
	export K2HR3CLI_REQUEST_FILE="${TESTDIR}/util_dbaas_request.sh"
fi

#
# Load K2HR3 Test dummy response file
#
UTIL_REQUESTFILE="util_request.sh"
if [ -f "${TESTDIR}/${UTIL_REQUESTFILE}" ]; then
	. "${TESTDIR}/${UTIL_REQUESTFILE}"
fi

#
# Load utility file for test
#
UTIL_TESTFILE="util_test.sh"
if [ -f "${TESTDIR}/${UTIL_TESTFILE}" ]; then
	. "${TESTDIR}/${UTIL_TESTFILE}"
fi

#
# Response Header File
#
K2HR3CLI_REQUEST_RESHEADER_FILE="/tmp/.${BINNAME}_$$_curl.header"

#
# Test for common values
#
_TEST_K2HR3_USER="test"
_TEST_K2HR3_PASS="password"
_TEST_K2HR3_TENANT="test1"
_TEST_K2HDKC_CLUSTER_NAME="testcluster"

#--------------------------------------------------------------
# DBaaS Response for All test
#--------------------------------------------------------------
#
# Create Dummy DBaaS Response(proxying)
#
create_dummy_dbaas_response()
{
	#
	# Call own test response function
	#
	create_dummy_dbaas_response_sub "$@"
	if [ $? -eq 3 ]; then
		#
		# Cases that I did not handle myself, Call k2hr3_cli test response function.
		#
		prn_dbg "(create_dummy_dbaas_response) Delegate requests that are not handled by DBaaS to create_dummy_response."
		create_dummy_response "$@"
	fi
	return $?
}

#
# Create Dummy DBaaS Response Sub
#
# $1								: Method(GET/PUT/POST/HEAD/DELETE)
# $2								: URL path and parameters in request
# $3								: body data(string) for post
# $4								: body data(file path) for post
# $5								: need content type header (* this value is not used)
# $6...								: other headers (do not include spaces in each header)
#
# $?								: result
#										0	success(request completed successfully, need to check K2HR3CLI_REQUEST_EXIT_CODE for the processing result)
#									  	1	failure(if the curl request fails)
#										2	fatal error
#										3	not handling
# Set global values
#	K2HR3CLI_REQUEST_EXIT_CODE		: http response code
#	K2HR3CLI_REQUEST_RESULT_FILE	: request result content file
#
create_dummy_dbaas_response_sub()
{
	if [ $# -lt 2 ]; then
		prn_err "Missing options for calling request."
		return 2
	fi

	#
	# Check Parameters
	#
	_DUMMY_METHOD="$1"
	if [ -z "${_DUMMY_METHOD}" ] || { [ "${_DUMMY_METHOD}" != "GET" ] && [ "${_DUMMY_METHOD}" != "HEAD" ] && [ "${_DUMMY_METHOD}" != "PUT" ] && [ "${_DUMMY_METHOD}" != "POST" ] && [ "${_DUMMY_METHOD}" != "DELETE" ]; }; then
		prn_err "Unknown Method($1) options for calling requet."
		return 2
	fi

	_DUMMY_URL_FULL="$2"
	_DUMMY_URL_PATH=$(echo "${_DUMMY_URL_FULL}" | sed -e 's/?.*$//g' -e 's/&.*$//g')

	if pecho -n "${_DUMMY_URL_FULL}" | grep -q '[?|&]'; then
		_DUMMY_URL_ARGS=$(pecho -n "${_DUMMY_URL_FULL}" | sed -e 's/^.*?//g')
	else
		_DUMMY_URL_ARGS=""
	fi
	prn_dbg "(create_dummy_dbaas_response_sub) all url(${_DUMMY_METHOD}: ${_DUMMY_URL_FULL}) => url(${_DUMMY_METHOD}: ${_DUMMY_URL_PATH}) + args(${_DUMMY_URL_ARGS})"

	_DUMMY_BODY_STRING="$3"
	_DUMMY_BODY_FILE="$4"
	_DUMMY_CONTENT_TYPE="$5"
	if [ $# -le 5 ]; then
		shift $#
	else
		shift 5
	fi

	#
	# Common values
	#
	_UTIL_DBAAS_RESPONSE_DATE=$(date -R)
	_UTIL_DBAAS_ISSUED_AT_DATE=$(date '+%Y-%m-%dT%H:%M:%S.000000Z')

	#
	# Parse request
	#
	if [ -n "${K2HR3CLI_OVERRIDE_URI}" ]; then
		#------------------------------------------------------
		# Request for OpenStack API
		#------------------------------------------------------
		if [ -z "${_DUMMY_URL_PATH}" ]; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Unknown URL(OpenStack URI: empty)."
			return 2

		elif [ "${_DUMMY_URL_PATH}" = "/v3/auth/tokens" ]; then
			#------------------------------------------------------
			# OpenStack Token
			#------------------------------------------------------
			if [ -z "${_DUMMY_METHOD}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Unknown URL(OpenStack URI: empty: ${_DUMMY_URL_PATH})."
				return 2

			elif [ "${_DUMMY_METHOD}" = "POST" ]; then
				if pecho -n "${_DUMMY_BODY_STRING}" | grep -q 'scope'; then
					#
					# Create OpenStack Scoped Token
					#
					if ! pecho -n "${_DUMMY_BODY_STRING}" | grep 'scope' | grep 'project' | grep -q 'TEST_TENANT_ID'; then
						K2HR3CLI_REQUEST_EXIT_CODE=400
						prn_err "Create OpenStack Scoped Token, Tenant id is not found."
						return 2
					fi

					if util_search_urlarg "nocatalog" "${_DUMMY_URL_ARGS}"; then
						_UTIL_DBAAS_RESPONSE_CONTENT="{\"token\":{\"audit_ids\":[\"TEST_TOKEN_AUDIT_ID\"],\"expires_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"is_domain\":false,\"issued_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"methods\":[\"token\",\"password\"],\"project\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"TEST_PROJECT_ID\",\"name\":\"demo\"},\"roles\":[{\"id\":\"TEST_MEMBER_ROLE_ID\",\"name\":\"member\"},{\"id\":\"TEST_READER_ROLE_ID\",\"name\":\"reader\"},{\"id\":\"TEST_OTHER_ROLE_ID\",\"name\":\"anotherrole\"}],\"user\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"TEST_USER_ID\",\"name\":\"test\",\"password_expires_at\":null}}}"
					else
						_UTIL_DBAAS_RESPONSE_CONTENT="{\"token\":{\"audit_ids\":[\"TEST_TOKEN_AUDIT_ID\"],\"catalog\":[{\"endpoints\":[{\"id\":\"TEST_OP_NOVA_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/compute/v2.1\"}],\"id\":\"TEST_OP_NOVA_MAIN_ID\",\"name\":\"nova\",\"type\":\"compute\"},{\"endpoints\":[{\"id\":\"TEST_OP_PUB_KEYSTONE_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/identity\"},{\"id\":\"TEST_OP_ADMIN_KEYSTONE_ID\",\"interface\":\"admin\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/identity\"}],\"id\":\"TEST_OP_MAIN_KEYSTONE_ID\",\"name\":\"keystone\",\"type\":\"identity\"},{\"endpoints\":[{\"id\":\"TEST_OP_NEUTRON_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost:9696/\"}],\"id\":\"TEST_OP_MAIN_NEUTRON_ID\",\"name\":\"neutron\",\"type\":\"network\"},{\"endpoints\":[{\"id\":\"TEST_OP_GLANCE_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/image\"}],\"id\":\"TEST_OP_MAIN_GLANCE_ID\",\"name\":\"glance\",\"type\":\"image\"}],\"expires_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"is_domain\":false,\"issued_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"methods\":[\"token\",\"password\"],\"project\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"TEST_PROJECT_ID\",\"name\":\"demo\"},\"roles\":[{\"id\":\"TEST_MEMBER_ROLE_ID\",\"name\":\"member\"},{\"id\":\"TEST_READER_ROLE_ID\",\"name\":\"reader\"},{\"id\":\"TEST_OTHER_ROLE_ID\",\"name\":\"anotherrole\"}],\"user\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"TEST_USER_ID\",\"name\":\"test\",\"password_expires_at\":null}}}"
					fi
					pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

					{
						pecho "Date: ${_UTIL_DBAAS_RESPONSE_DATE}";
						pecho "Content-Type: application/json";
						pecho "Content-Length: ${#_UTIL_DBAAS_RESPONSE_CONTENT}";
						pecho "X-Subject-Token: TEST_USER_OPENSTACK_SCOPED_TOKEN";
						pecho "Vary: X-Auth-Token";
						pecho "x-openstack-request-id: REQ-POST-USER_SCOPED_TOKEN";
						pecho "Connection: close";
					} > "${K2HR3CLI_REQUEST_RESHEADER_FILE}"


					K2HR3CLI_REQUEST_EXIT_CODE=201

				else
					#
					# Create OpenStack Unscoped Token
					#
					_UTIL_DBAAS_RESPONSE_CONTENT="{\"token\":{\"methods\":[\"password\"],\"user\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"OP_TEST_USER_ID\",\"name\":\"demo\",\"password_expires_at\":null},\"audit_ids\":[\"OP_TEST_USER_AUDIT_ID\"],\"expires_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"issued_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}}"
					pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

					{
						pecho "Date: ${_UTIL_DBAAS_RESPONSE_DATE}";
						pecho "Content-Type: application/json";
						pecho "Content-Length: ${#_UTIL_DBAAS_RESPONSE_CONTENT}";
						pecho "X-Subject-Token: TEST_USER_OPENSTACK_UNSCOPED_TOKEN";
						pecho "Vary: X-Auth-Token";
						pecho "x-openstack-request-id: REQ-POST-USER_UNSCOPED_TOKEN";
						pecho "Connection: close";
					} > "${K2HR3CLI_REQUEST_RESHEADER_FILE}"

					K2HR3CLI_REQUEST_EXIT_CODE=201
				fi

			elif [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Get OpenStack Token Info
				#
				if [ $# -lt 1 ]; then
					prn_err "\"X-Auth-Token\" header is not specified."
					return 2
				fi
				#
				# Search X-Auth-Token header
				#
				for _TEST_ONE_TOKEN_HEADER_POS in $(seq 1 $#); do
					# shellcheck disable=SC1083,SC2039
					_TEST_ONE_TOKEN_HEADER=$(eval echo '$'{"${_TEST_ONE_TOKEN_HEADER_POS}"})
					_TEST_OPENSTACK_TOKEN=$(pecho -n "${_TEST_ONE_TOKEN_HEADER}" | grep '^X-Auth-Token:' | sed -e 's/X-Auth-Token:[[:space:]]*\(.*\)[[:space:]]*$/\1/g')
					if [ -n "${_TEST_OPENSTACK_TOKEN}" ] && [ "${_TEST_OPENSTACK_TOKEN}" = "TEST_USER_OPENSTACK_UNSCOPED_TOKEN" ]; then
						#
						# Unscoped Token
						#
						_UTIL_DBAAS_RESPONSE_CONTENT="{\"token\":{\"audit_ids\":[\"TEST_TOKEN_AUDIT_ID\"],\"expires_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"issued_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"methods\":[\"password\"],\"user\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"TEST_USER_ID\",\"name\":\"test\",\"password_expires_at\":null}}}"
						pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

						K2HR3CLI_REQUEST_EXIT_CODE=200
						return 0


					elif [ -n "${_TEST_OPENSTACK_TOKEN}" ] && [ "${_TEST_OPENSTACK_TOKEN}" = "TEST_USER_OPENSTACK_SCOPED_TOKEN" ]; then
						#
						# Scoped Token
						#
						if util_search_urlarg "nocatalog" "${_DUMMY_URL_ARGS}"; then
							_UTIL_DBAAS_RESPONSE_CONTENT="{\"token\":{\"audit_ids\":[\"TEST_TOKEN_AUDIT_ID\"],\"expires_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"is_domain\":false,\"issued_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"methods\":[\"token\",\"password\"],\"project\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"TEST_PROJECT_ID\",\"name\":\"demo\"},\"roles\":[{\"id\":\"TEST_MEMBER_ROLE_ID\",\"name\":\"member\"},{\"id\":\"TEST_READER_ROLE_ID\",\"name\":\"reader\"},{\"id\":\"TEST_OTHER_ROLE_ID\",\"name\":\"anotherrole\"}],\"user\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"TEST_USER_ID\",\"name\":\"test\",\"password_expires_at\":null}}}"
						else
							_UTIL_DBAAS_RESPONSE_CONTENT="{\"token\":{\"audit_ids\":[\"TEST_TOKEN_AUDIT_ID\"],\"catalog\":[{\"endpoints\":[{\"id\":\"TEST_OP_NOVA_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/compute/v2.1\"}],\"id\":\"TEST_OP_NOVA_MAIN_ID\",\"name\":\"nova\",\"type\":\"compute\"},{\"endpoints\":[{\"id\":\"TEST_OP_PUB_KEYSTONE_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/identity\"},{\"id\":\"TEST_OP_ADMIN_KEYSTONE_ID\",\"interface\":\"admin\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/identity\"}],\"id\":\"TEST_OP_MAIN_KEYSTONE_ID\",\"name\":\"keystone\",\"type\":\"identity\"},{\"endpoints\":[{\"id\":\"TEST_OP_NEUTRON_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost:9696/\"}],\"id\":\"TEST_OP_MAIN_NEUTRON_ID\",\"name\":\"neutron\",\"type\":\"network\"},{\"endpoints\":[{\"id\":\"TEST_OP_GLANCE_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/image\"}],\"id\":\"TEST_OP_MAIN_GLANCE_ID\",\"name\":\"glance\",\"type\":\"image\"}],\"expires_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"is_domain\":false,\"issued_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"methods\":[\"token\",\"password\"],\"project\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"TEST_PROJECT_ID\",\"name\":\"demo\"},\"roles\":[{\"id\":\"TEST_MEMBER_ROLE_ID\",\"name\":\"member\"},{\"id\":\"TEST_READER_ROLE_ID\",\"name\":\"reader\"},{\"id\":\"TEST_OTHER_ROLE_ID\",\"name\":\"anotherrole\"}],\"user\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"TEST_USER_ID\",\"name\":\"test\",\"password_expires_at\":null}}}"
						fi
						pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"
						
						K2HR3CLI_REQUEST_EXIT_CODE=200
						return 0

					elif [ -n "${_TEST_OPENSTACK_TOKEN}" ]; then
						#
						# Unknown token string -> so it returns expired
						#
						K2HR3CLI_REQUEST_EXIT_CODE=400
						prn_err "Get OpenStack Token information, token is unknown(${_TEST_OPENSTACK_TOKEN})."
						return 2
					fi
				done
				prn_err "\"X-Auth-Token\" header is not specified."
				return 2

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Unknown URL(OpenStack URI: ${_DUMMY_METHOD}: ${_DUMMY_URL_PATH})."
				return 2
			fi

		elif [ "${_DUMMY_URL_PATH}" = "/v3/auth/catalog" ]; then
			#------------------------------------------------------
			# OpenStack Endpoint Catalog
			#------------------------------------------------------
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Get OpenStack Token Info
				#
				if [ $# -lt 1 ]; then
					prn_err "\"X-Auth-Token\" header is not specified."
					return 2
				fi

				_UTIL_DBAAS_RESPONSE_CONTENT="{\"catalog\":[{\"endpoints\":[{\"id\":\"TEST_OP_NOVA_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/compute/v2.1\"}],\"id\":\"TEST_OP_NOVA_MAIN_ID\",\"name\":\"nova\",\"type\":\"compute\"},{\"endpoints\":[{\"id\":\"TEST_OP_PUB_KEYSTONE_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/identity\"},{\"id\":\"TEST_OP_ADMIN_KEYSTONE_ID\",\"interface\":\"admin\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/identity\"}],\"id\":\"TEST_OP_MAIN_KEYSTONE_ID\",\"name\":\"keystone\",\"type\":\"identity\"},{\"endpoints\":[{\"id\":\"TEST_OP_NEUTRON_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost:9696/\"}],\"id\":\"TEST_OP_MAIN_NEUTRON_ID\",\"name\":\"neutron\",\"type\":\"network\"},{\"endpoints\":[{\"id\":\"TEST_OP_GLANCE_ID\",\"interface\":\"public\",\"region\":\"RegionOne\",\"region_id\":\"RegionOne\",\"url\":\"http://localhost/image\"}],\"id\":\"TEST_OP_MAIN_GLANCE_ID\",\"name\":\"glance\",\"type\":\"image\"}]}"
				pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				K2HR3CLI_REQUEST_EXIT_CODE=200
				return 0

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Unknown URL(OpenStack URI: ${_DUMMY_METHOD}: ${_DUMMY_URL_PATH})."
				return 2
			fi

		elif pecho -n "${_DUMMY_URL_PATH}" | grep -q '^/v3/users/[^/]*/projects'; then
			#------------------------------------------------------
			# OpenStack Project information
			#------------------------------------------------------
			_UTIL_DBAAS_USER_ID=$(pecho -n "${_DUMMY_URL_PATH}" | grep '^/v3/users/[^/]*/projects' | sed 's#^/v3/users/\([^/]*\)/projects$#\1#g')
			if [ -z "${_UTIL_DBAAS_USER_ID}" ] || [ "${_UTIL_DBAAS_USER_ID}" != "TEST_USER_ID" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Get User Project Information : Unknown user id(${_UTIL_DBAAS_USER_ID})."
				return 2
			fi

			_UTIL_DBAAS_RESPONSE_CONTENT="{\"links\":{\"next\":null,\"previous\":null,\"self\":\"http://localhost/identity/v3/users/${_UTIL_DBAAS_USER_ID}/projects\"},\"projects\":[{\"description\":\"\",\"domain_id\":\"default\",\"enabled\":true,\"id\":\"TEST_TENANT_ID\",\"is_domain\":false,\"links\":{\"self\":\"http://localhost/identity/v3/projects/TEST_TENANT_ID\"},\"name\":\"test1\",\"options\":{},\"parent_id\":\"default\",\"tags\":[]}]}"
			pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			K2HR3CLI_REQUEST_EXIT_CODE=200
			return 0

		elif [ "${_DUMMY_URL_PATH}" = "/v2.0/security-groups" ]; then
			#------------------------------------------------------
			# OpenStack Security Group
			#------------------------------------------------------
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Security Group Information
				#

				# [NOTE]
				# Since the condition becomes complicated, use "X"(temporary word).
				#
				if [ "X${K2HR3CLI_SUBCOMMAND}" = "X${_DATABASE_COMMAND_SUB_CREATE}" ]; then
					#
					# In the case of Create command, a non-existent response is returned.
					#
					_UTIL_DBAAS_RESPONSE_CONTENT="{\"security_groups\":[{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"Default security group\",\"id\":\"TEST_SECGROUP_DEFAULT_ID\",\"name\":\"default\",\"project_id\":\"TEST_TENANT_ID\",\"revision_number\":1,\"security_group_rules\":[{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":null,\"direction\":\"egress\",\"ethertype\":\"IPv4\",\"id\":\"TEST_SECRULE_IPV4_ID\",\"port_range_max\":null,\"port_range_min\":null,\"project_id\":\"TEST_TENANT_ID\",\"protocol\":null,\"remote_group_id\":null,\"remote_ip_prefix\":null,\"revision_number\":0,\"security_group_id\":\"TEST_SECGROUP_DEFAULT_ID\",\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}],\"stateful\":true,\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}]}"
				else
					#
					# If it is other than Create, it returns an existing response.
					#
					_UTIL_DBAAS_RESPONSE_CONTENT="{\"security_groups\":[{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"Default security group\",\"id\":\"TEST_SECGROUP_DEFAULT_ID\",\"name\":\"default\",\"project_id\":\"TEST_TENANT_ID\",\"revision_number\":1,\"security_group_rules\":[{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":null,\"direction\":\"egress\",\"ethertype\":\"IPv4\",\"id\":\"TEST_SECRULE_IPV4_ID\",\"port_range_max\":null,\"port_range_min\":null,\"project_id\":\"TEST_TENANT_ID\",\"protocol\":null,\"remote_group_id\":null,\"remote_ip_prefix\":null,\"revision_number\":0,\"security_group_id\":\"TEST_SECGROUP_DEFAULT_ID\",\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}],\"stateful\":true,\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"},{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"security group for k2hdkc testcluster server node\",\"id\":\"TEST_SECGROUP_SERVER_ID\",\"name\":\"${_TEST_K2HDKC_CLUSTER_NAME}-k2hdkc-server-sec\",\"project_id\":\"TEST_TENANT_ID\",\"revision_number\":4,\"security_group_rules\":[{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"k2hdkc/chmpx server node control port\",\"direction\":\"ingress\",\"ethertype\":\"IPv4\",\"id\":\"TEST_SECRULE_SERVER_IPV4_2_ID\",\"port_range_max\":98021,\"port_range_min\":98021,\"project_id\":\"TEST_TENANT_ID\",\"protocol\":\"tcp\",\"remote_group_id\":null,\"remote_ip_prefix\":null,\"revision_number\":0,\"security_group_id\":\"TEST_SECGROUP_SERVER_ID\",\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"},{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"k2hdkc/chmpx server node port\",\"direction\":\"ingress\",\"ethertype\":\"IPv4\",\"id\":\"TEST_SECRULE_SERVER_IPV4_1_ID\",\"port_range_max\":98020,\"port_range_min\":98020,\"project_id\":\"TEST_TENANT_ID\",\"protocol\":\"tcp\",\"remote_group_id\":null,\"remote_ip_prefix\":null,\"revision_number\":0,\"security_group_id\":\"TEST_SECGROUP_SERVER_ID\",\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}],\"stateful\":true,\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"},{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"security group for k2hdkc testcluster slave node\",\"id\":\"TEST_SECGROUP_SLAVE_ID\",\"name\":\"${_TEST_K2HDKC_CLUSTER_NAME}-k2hdkc-slave-sec\",\"project_id\":\"TEST_TENANT_ID\",\"revision_number\":3,\"security_group_rules\":[{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"k2hdkc/chmpx slave node control port\",\"direction\":\"ingress\",\"ethertype\":\"IPv4\",\"id\":\"TEST_SECRULE_SLAVE_IPV4_1_ID\",\"port_range_max\":98031,\"port_range_min\":98031,\"project_id\":\"TEST_TENANT_ID\",\"protocol\":\"tcp\",\"remote_group_id\":null,\"remote_ip_prefix\":null,\"revision_number\":0,\"security_group_id\":\"TEST_SECGROUP_SLAVE_ID\",\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}],\"stateful\":true,\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}]}"
				fi
				pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				K2HR3CLI_REQUEST_EXIT_CODE=200
				return 0

			elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "POST" ]; then
				#
				# Create Security Group
				#
				# [NOTE]
				# The caller only checks the ID and does not return exact data.
				#
				_UTIL_DBAAS_SECGRP_TYPE=$(pecho -n "${_DUMMY_BODY_STRING}" | grep '"name":[[:space:]]*".*",.*$' | sed -e 's/^.*"name":[[:space:]]*"\([^\"]*\)",.*$/\1/g' -e 's/^[^-]*-k2hdkc-\([^-]*\)-.*$/\1/g')

				if [ -n "${_UTIL_DBAAS_SECGRP_TYPE}" ] && [ "${_UTIL_DBAAS_SECGRP_TYPE}" = "server" ]; then
					_UTIL_DBAAS_RESPONSE_CONTENT="{\"security_groups\":[{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"security group for k2hdkc testcluster server node\",\"id\":\"TEST_SECGROUP_SERVER_ID\",\"name\":\"${_TEST_K2HDKC_CLUSTER_NAME}-k2hdkc-server-sec\",\"project_id\":\"TEST_TENANT_ID\",\"revision_number\":4,\"security_group_rules\":[{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"k2hdkc/chmpx server node control port\",\"direction\":\"ingress\",\"ethertype\":\"IPv4\",\"id\":\"TEST_SECRULE_SERVER_IPV4_2_ID\",\"port_range_max\":98021,\"port_range_min\":98021,\"project_id\":\"TEST_TENANT_ID\",\"protocol\":\"tcp\",\"remote_group_id\":null,\"remote_ip_prefix\":null,\"revision_number\":0,\"security_group_id\":\"TEST_SECGROUP_SERVER_ID\",\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"},{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"k2hdkc/chmpx server node port\",\"direction\":\"ingress\",\"ethertype\":\"IPv4\",\"id\":\"TEST_SECRULE_SERVER_IPV4_1_ID\",\"port_range_max\":98020,\"port_range_min\":98020,\"project_id\":\"TEST_TENANT_ID\",\"protocol\":\"tcp\",\"remote_group_id\":null,\"remote_ip_prefix\":null,\"revision_number\":0,\"security_group_id\":\"TEST_SECGROUP_SERVER_ID\",\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}],\"stateful\":true,\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}]}"
				else
					_UTIL_DBAAS_RESPONSE_CONTENT="{\"security_groups\":[{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"security group for k2hdkc testcluster slave node\",\"id\":\"TEST_SECGROUP_SLAVE_ID\",\"name\":\"${_TEST_K2HDKC_CLUSTER_NAME}-k2hdkc-slave-sec\",\"project_id\":\"TEST_TENANT_ID\",\"revision_number\":3,\"security_group_rules\":[{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"k2hdkc/chmpx slave node control port\",\"direction\":\"ingress\",\"ethertype\":\"IPv4\",\"id\":\"TEST_SECRULE_SLAVE_IPV4_1_ID\",\"port_range_max\":98031,\"port_range_min\":98031,\"project_id\":\"TEST_TENANT_ID\",\"protocol\":\"tcp\",\"remote_group_id\":null,\"remote_ip_prefix\":null,\"revision_number\":0,\"security_group_id\":\"TEST_SECGROUP_SLAVE_ID\",\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}],\"stateful\":true,\"tags\":[],\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}]}"
				fi

				pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				K2HR3CLI_REQUEST_EXIT_CODE=201
				return 0

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Unknown URL(OpenStack URI: ${_DUMMY_METHOD}: ${_DUMMY_URL_PATH})."
				return 2
			fi

		elif pecho -n "${_DUMMY_URL_PATH}" | grep -q "^/v2.0/security-groups/"; then
			#------------------------------------------------------
			# OpenStack Security Group
			#------------------------------------------------------
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "DELETE" ]; then
				#
				# Delete Security Group
				#
				_UTIL_DBAAS_RESPONSE_CONTENT=""
				pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				K2HR3CLI_REQUEST_EXIT_CODE=204
				return 0

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Unknown URL(OpenStack URI: ${_DUMMY_METHOD}: ${_DUMMY_URL_PATH})."
				return 2
			fi

		elif [ "${_DUMMY_URL_PATH}" = "/v2.0/security-group-rules" ]; then
			#------------------------------------------------------
			# OpenStack Security Group Rule
			#------------------------------------------------------
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "POST" ]; then
				#
				# Create Security Group Rule
				#
				# [NOTE]
				# The caller only checks the ID and does not return exact data.
				#
				_UTIL_DBAAS_SECGRP_DESC=$(pecho -n "${_DUMMY_BODY_STRING}" | sed 's/^.*"description":[[:space:]]*"\([^"]*\)".*$/\1/g')
				_UTIL_DBAAS_SECGRP_MAX=$(pecho -n "${_DUMMY_BODY_STRING}" | sed 's/^.*"port_range_max":[[:space:]]*\([^,]*\),.*$/\1/g')
				_UTIL_DBAAS_SECGRP_MIN=$(pecho -n "${_DUMMY_BODY_STRING}" | sed 's/^.*"port_range_min":[[:space:]]*\([^,]*\),.*$/\1/g')
				_UTIL_DBAAS_SECGRP_ID=$(pecho -n "${_DUMMY_BODY_STRING}" | sed 's/^.*"security_group_id":[[:space:]]*"\([^"]*\)".*$/\1/g')

				_UTIL_DBAAS_RESPONSE_CONTENT="{\"security_group_rule\":{\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"description\":\"${_UTIL_DBAAS_SECGRP_DESC}\",\"direction\":\"ingress\",\"ethertype\":\"IPv4\",\"id\":\"TEST_TENANT_ID\",\"port_range_max\":${_UTIL_DBAAS_SECGRP_MAX},\"port_range_min\":${_UTIL_DBAAS_SECGRP_MIN},\"project_id\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"protocol\":\"tcp\",\"remote_group_id\":null,\"remote_ip_prefix\":null,\"revision_number\":0,\"security_group_id\":\"${_UTIL_DBAAS_SECGRP_ID}\",\"tenant_id\":\"TEST_TENANT_ID\",\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\"}}"
				pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				K2HR3CLI_REQUEST_EXIT_CODE=201
				return 0

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Unknown URL(OpenStack URI: ${_DUMMY_METHOD}: ${_DUMMY_URL_PATH})."
				return 2
			fi

		elif [ "${_DUMMY_URL_PATH}" = "/os-keypairs" ]; then
			#------------------------------------------------------
			# OpenStack Keypair
			#------------------------------------------------------
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Get Keypair list
				#
				_UTIL_DBAAS_RESPONSE_CONTENT="{\"keypairs\":[{\"keypair\":{\"fingerprint\":\"00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00\",\"name\":\"TEST_KEYPAIR\",\"public_key\":\"ssh-rsa test_keypair_public_key_contents testuser@localhost\"}}]}"
				pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				K2HR3CLI_REQUEST_EXIT_CODE=200
				return 0

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Unknown URL(OpenStack URI: ${_DUMMY_METHOD}: ${_DUMMY_URL_PATH})."
				return 2
			fi

		elif [ "${_DUMMY_URL_PATH}" = "/v2/images" ]; then
			#------------------------------------------------------
			# OpenStack Glance
			#------------------------------------------------------
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Get Image list
				#
				_UTIL_DBAAS_RESPONSE_CONTENT="{\"first\":\"/v2/images\",\"images\":[{\"checksum\":\"TEST_IMAGE_CHECKSUM\",\"container_format\":\"bare\",\"created_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"disk_format\":\"qcow2\",\"file\":\"/v2/images/TEST_IMAGE_ID/file\",\"id\":\"TEST_IMAGE_ID\",\"min_disk\":0,\"min_ram\":0,\"name\":\"TEST_IMAGE\",\"os_hash_algo\":\"sha512\",\"os_hash_value\":\"TEST_OS_HASH_VALUE\",\"os_hidden\":false,\"owner\":\"TEST_USER_ID\",\"owner_specified.openstack.md5\":\"\",\"owner_specified.openstack.object\":\"images/TEST_IMAGE\",\"owner_specified.openstack.sha256\":\"\",\"protected\":false,\"schema\":\"/v2/schemas/image\",\"self\":\"/v2/images/TEST_IMAGE_ID\",\"size\":327680000,\"status\":\"active\",\"tags\":[],\"updated_at\":\"${_UTIL_DBAAS_ISSUED_AT_DATE}\",\"virtual_size\":null,\"visibility\":\"public\"}],\"schema\":\"/v2/schemas/images\"}"
				pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				K2HR3CLI_REQUEST_EXIT_CODE=200
				return 0

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Unknown URL(OpenStack URI: ${_DUMMY_METHOD}: ${_DUMMY_URL_PATH})."
				return 2
			fi

		elif [ "${_DUMMY_URL_PATH}" = "/flavors/detail" ]; then
			#------------------------------------------------------
			# OpenStack Flavor
			#------------------------------------------------------
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Get Flavor list
				#
				_UTIL_DBAAS_RESPONSE_CONTENT="{\"flavors\":[{\"OS-FLV-DISABLED:disabled\":false,\"OS-FLV-EXT-DATA:ephemeral\":0,\"disk\":10,\"id\":\"TEST_FLAVOR_ID\",\"links\":[{\"href\":\"http://localhost/compute/v2.1/TEST_TENANT_ID/flavors/TEST_FLAVOR_ID\",\"rel\":\"self\"},{\"href\":\"http://localhost/compute/TEST_TENANT_ID/flavors/TEST_FLAVOR_ID\",\"rel\":\"bookmark\"}],\"name\":\"TEST_FLAVOR\",\"os-flavor-access:is_public\":true,\"ram\":2048,\"rxtx_factor\":1.0,\"swap\":\"\",\"vcpus\":2}]}"
				pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				K2HR3CLI_REQUEST_EXIT_CODE=200
				return 0

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Unknown URL(OpenStack URI: ${_DUMMY_METHOD}: ${_DUMMY_URL_PATH})."
				return 2
			fi

		elif pecho -n "${_DUMMY_URL_PATH}" | grep -q "^/servers$"; then
			#------------------------------------------------------
			# OpenStack Create Servers (/servers)
			#------------------------------------------------------
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "POST" ]; then
				#
				# Create Servers
				#
				_UTIL_DBAAS_SERVER_TENANT_ID=$(pecho -n "${_DUMMY_URL_PATH}" | sed 's#^/\([^/]*\)/servers$#\1#g')

				_UTIL_DBAAS_RESPONSE_CONTENT="{\"server\":{\"id\":\"TESTSERVER_ID\",\"links\":[{\"rel\":\"self\",\"href\":\"http://localhost/compute/v2.1/${_UTIL_DBAAS_SERVER_TENANT_ID}/servers/TESTSERVER_ID\"},{\"rel\":\"bookmark\",\"href\":\"http://localhost/compute/${_UTIL_DBAAS_SERVER_TENANT_ID}/servers/TESTSERVER_ID\"}],\"OS-DCF:diskConfig\":\"MANUAL\",\"security_groups\":[{\"name\":\"default\"}],\"adminPass\":\"TEST_ADMIN_PASS\"}}"
				pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				K2HR3CLI_REQUEST_EXIT_CODE=202
				return 0

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Unknown URL(OpenStack URI: ${_DUMMY_METHOD}: ${_DUMMY_URL_PATH})."
				return 2
			fi

		elif pecho -n "${_DUMMY_URL_PATH}" | grep -q "^/servers/.*$"; then
			#------------------------------------------------------
			# OpenStack Delete Server (/servers/<server id>)
			#------------------------------------------------------
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "DELETE" ]; then
				#
				# Delete Server
				#
				_UTIL_DBAAS_RESPONSE_CONTENT=""
				pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				K2HR3CLI_REQUEST_EXIT_CODE=204
				return 0

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Unknown URL(OpenStack URI: ${_DUMMY_METHOD}: ${_DUMMY_URL_PATH})."
				return 2
			fi

		else
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Unknown URL(OpenStack URI: ${_DUMMY_URL_PATH})."
			return 2
		fi

	else
		#------------------------------------------------------
		# Request for K2HR3 API (Override k2hr3 test response)
		#------------------------------------------------------
		if pecho -n "${_DUMMY_URL_PATH}" | grep -v "^/v1/role/token/" | grep -v "/v1/user/tokens" | grep -q "^/v1/role/"; then
			#------------------------------------------------------
			# K2HR3 Role API
			#------------------------------------------------------
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Set role information
				#
				if pecho -n "${_DUMMY_URL_ARGS}" | grep -q "expand=true"; then
					_UTIL_DBAAS_EXPAND=1
				else
					_UTIL_DBAAS_EXPAND=0
				fi
				if pecho -n "${_DUMMY_URL_PATH}" | grep -q "server"; then
					if [ "${_UTIL_DBAAS_EXPAND}" -eq 0 ]; then
						_UTIL_DBAAS_RESPONSE_CONTENT="{\"result\":true,\"message\":null,\"role\":{\"policies\":[],\"aliases\":[],\"hosts\":{\"hostnames\":[],\"ips\":[\"127.0.0.1 * TESTSERVER_ID openstack-auto-v1 TESTSERVER\"]}}}"
					else
						_UTIL_DBAAS_RESPONSE_CONTENT="{\"result\":true,\"message\":null,\"role\":{\"policies\":[\"yrn:yahoo:::demo:policy:${_TEST_K2HDKC_CLUSTER_NAME}\"]}}"
					fi
				else
					if [ "${_UTIL_DBAAS_EXPAND}" -eq 0 ]; then
						_UTIL_DBAAS_RESPONSE_CONTENT="{\"result\":true,\"message\":null,\"role\":{\"policies\":[],\"aliases\":[],\"hosts\":{\"hostnames\":[],\"ips\":[\"127.0.0.1 * TESTSLAVE_ID openstack-auto-v1 TESTSLAVE\"]}}}"
					else
						_UTIL_DBAAS_RESPONSE_CONTENT="{\"result\":true,\"message\":null,\"role\":{\"policies\":[\"yrn:yahoo:::demo:policy:${_TEST_K2HDKC_CLUSTER_NAME}\"]}}"
					fi
				fi
				pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				K2HR3CLI_REQUEST_EXIT_CODE=200
				return 0
			fi

		elif pecho -n "${_DUMMY_URL_PATH}" | grep -q "^/v1/resource/"; then
			#------------------------------------------------------
			# K2HR3 Resource API
			#------------------------------------------------------
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Set role information
				#
				if pecho -n "${_DUMMY_URL_ARGS}" | grep -q "expand=true"; then
					if pecho -n "${_DUMMY_URL_PATH}" | grep -q "server"; then
						_UTIL_DBAAS_RESPONSE_CONTENT="{\"result\":true,\"message\":null,\"resource\":{\"string\":\"TEST_DUMMY_RESOURCE_FOR_SERVER\",\"object\":null,\"keys\":{\"cluster-name\":\"${_TEST_K2HDKC_CLUSTER_NAME}\",\"chmpx-server-port\":98020,\"chmpx-server-ctlport\":98021,\"chmpx-slave-ctlport\":98031,\"k2hdkc-dbaas-add-user\":1,\"k2hdkc-dbaas-proc-user\":\"testrunner\",\"chmpx-mode\":\"SERVER\",\"k2hr3-init-packages\":\"\",\"k2hr3-init-packagecloud-packages\":\"k2hdkc-dbaas-override-conf,k2hr3-get-resource,chmpx,k2hdkc\",\"k2hr3-init-systemd-packages\":\"chmpx.service,k2hdkc.service,k2hr3-get-resource.timer\",\"host_key\":\"127.0.0.1,0,TESTSERVER_ID\",\"one_host\":{\"host\":\"127.0.0.1\",\"port\":0,\"extra\":\"openstack-auto-v1\",\"tag\":\"TESTSERVER\",\"cuk\":\"TESTSERVER_ID\"}},\"expire\":null}}"
					else
						_UTIL_DBAAS_RESPONSE_CONTENT="{\"result\":true,\"message\":null,\"resource\":{\"string\":\"TEST_DUMMY_RESOURCE_FOR_SLAVE\",\"object\":null,\"keys\":{\"cluster-name\":\"${_TEST_K2HDKC_CLUSTER_NAME}\",\"chmpx-server-port\":98020,\"chmpx-server-ctlport\":98021,\"chmpx-slave-ctlport\":98031,\"k2hdkc-dbaas-add-user\":1,\"k2hdkc-dbaas-proc-user\":\"testrunner\",\"chmpx-mode\":\"SLAVE\",\"k2hr3-init-packages\":\"\",\"k2hr3-init-packagecloud-packages\":\"k2hdkc-dbaas-override-conf,k2hr3-get-resource,chmpx,k2hdkc\",\"k2hr3-init-systemd-packages\":\"chmpx.service,k2hdkc.service,k2hr3-get-resource.timer\",\"host_key\":\"127.0.0.1,0,TESTSLAVE_ID\",\"one_host\":{\"host\":\"127.0.0.1\",\"port\":0,\"extra\":\"openstack-auto-v1\",\"tag\":\"TESTSLAVE\",\"cuk\":\"TESTSLAVE_ID\"}},\"expire\":null}}"
					fi
					pecho "${_UTIL_DBAAS_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

					K2HR3CLI_REQUEST_EXIT_CODE=200
					return 0
				fi
			fi
		fi
		return 3
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
