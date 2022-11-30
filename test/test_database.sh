#!/bin/sh
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

#---------------------------------------------------------------------
# Variables
#---------------------------------------------------------------------
TESTNAME=$(basename "$0")
# shellcheck disable=SC2034
TESTBASENAME=$(echo "${TESTNAME}" | sed 's/[.]sh$//')
TESTDIR=$(dirname "$0")
TESTDIR=$(cd "${TESTDIR}" || exit 1; pwd)

#
# Special Environment
#
# [NOTE]
# The TEST_CREATE_DUMMY_FUNCTION environment variable modifies
# the behavior of the xxx_request() function in util_request.sh
# (k2hr3_cli).
# This environment variable is set to the create_dummy_response()
# function by default when util_request.sh(k2hr3_cli) is loaded.
# After loading this util_request.sh(k2hr3_cli), override the
# TEST_CREATE_DUMMY_RESPONSE_FUNC environment variable and replace
# it with the create_dummy_dbaas_response() function in this file.
# The create_dummy_dbaas_response() function handles the database
# command only.
# Otherwise, call the original create_dummy_response() function
# and let it do the work.
# This allows for dedicated testing of plugins.
#
export TEST_CREATE_DUMMY_RESPONSE_FUNC="create_dummy_dbaas_response"

#
# Load DBaaS dummy request file
#
export K2HR3CLI_REQUEST_FILE="${TESTDIR}/util_dbaas_request.sh"
if [ -f "${K2HR3CLI_REQUEST_FILE}" ]; then
	. "${K2HR3CLI_REQUEST_FILE}"
fi

#
# Additional options for test
#
# [NOTE]
# Overwrite special options to common options(set to $@) in util_test.sh
# A value of --config specifies a file that does not exist.
# It's a warning, but be sure not to set it, as the test will fail if
# the real file affects the variable.
#
TEST_IDENTITY_URI="http://localhost:8080"
set -- "--config" "${TESTDIR}/k2hr3.config" "--apiuri" "http://localhost" "--openstack_identity_uri" "${TEST_IDENTITY_URI}" "--dbaas_config" "${TESTDIR}/../src/libexec/database"

#=====================================================================
# Test for Database
#=====================================================================
TEST_EXIT_CODE=0

#---------------------------------------------------------------------
# (1) Normal : Create OpenStack Unscoped Token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(1) Normal : Create OpenStack Unscoped Token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database openstack utoken --op_user "${_TEST_K2HR3_USER}" --op_passphrase "${_TEST_K2HR3_PASS}" "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (2) Normal : Create OpenStack Scoped Token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(2) Normal : Create OpenStack Scoped Token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database openstack token --openstacktoken TEST_USER_OPENSTACK_UNSCOPED_TOKEN --op_tenant "${_TEST_K2HR3_TENANT}" "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (3) Normal : Create Cluster
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(3) Normal : Create Cluster"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database create "${_TEST_K2HDKC_CLUSTER_NAME}" --chmpx_server_port 98020 --chmpx_server_ctlport 98021 --chmpx_slave_ctlport 98031 --dbaas_user testrunner --dbaas_create_user --scopedtoken "TEST_TOKEN_SCOPED_FOR_TENANT_${_TEST_K2HR3_TENANT}_USER_${_TEST_K2HR3_USER}" --openstacktoken TEST_USER_OPENSTACK_SCOPED_TOKEN "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi


#---------------------------------------------------------------------
# (4) Normal : Add server host to cluster
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(4) Normal : Add server host to cluster"
test_prn_title "${TEST_TITLE}"

#
# Run
#
# [NOTE]
# In this test, we have given --create_roletoken.
#
"${K2HR3CLIBIN}" database add host server "${_TEST_K2HDKC_CLUSTER_NAME}" TESTSERVER --op_keypair TEST_KEYPAIR --op_flavor TEST_FLAVOR --op_image TEST_IMAGE --create_roletoken --scopedtoken "TEST_TOKEN_SCOPED_FOR_TENANT_${_TEST_K2HR3_TENANT}_USER_${_TEST_K2HR3_USER}" --openstacktoken TEST_USER_OPENSTACK_SCOPED_TOKEN "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (5) Normal : Add slave host to cluster
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(5) Normal : Add slave host to cluster"
test_prn_title "${TEST_TITLE}"

#
# Run
#
# [NOTE]
# This test does not grant --create_roletoken.
#
"${K2HR3CLIBIN}" database add host slave "${_TEST_K2HDKC_CLUSTER_NAME}" TESTSLAVE --op_keypair TEST_KEYPAIR --op_flavor TEST_FLAVOR --op_image TEST_IMAGE --scopedtoken "TEST_TOKEN_SCOPED_FOR_TENANT_${_TEST_K2HR3_TENANT}_USER_${_TEST_K2HR3_USER}" --openstacktoken TEST_USER_OPENSTACK_SCOPED_TOKEN "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (6) Normal : Delete host to cluster
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(6) Normal : Delete host to cluster"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database delete host "${_TEST_K2HDKC_CLUSTER_NAME}" TESTSERVER --scopedtoken "TEST_TOKEN_SCOPED_FOR_TENANT_${_TEST_K2HR3_TENANT}_USER_${_TEST_K2HR3_USER}" --openstacktoken TEST_USER_OPENSTACK_SCOPED_TOKEN "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (7) Normal : Show server host list
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(7) Normal : Show server host list"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database show host server "${_TEST_K2HDKC_CLUSTER_NAME}" --json --scopedtoken "TEST_TOKEN_SCOPED_FOR_TENANT_${_TEST_K2HR3_TENANT}_USER_${_TEST_K2HR3_USER}" --openstacktoken TEST_USER_OPENSTACK_SCOPED_TOKEN "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (8) Normal : Show slave host list
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(8) Normal : Show slave host list"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database show host slave "${_TEST_K2HDKC_CLUSTER_NAME}" --json --scopedtoken "TEST_TOKEN_SCOPED_FOR_TENANT_${_TEST_K2HR3_TENANT}_USER_${_TEST_K2HR3_USER}" --openstacktoken TEST_USER_OPENSTACK_SCOPED_TOKEN "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (9) Normal : Show server configuration
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(9) Normal : Show server configuration"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database show configuration server "${_TEST_K2HDKC_CLUSTER_NAME}" --json --scopedtoken "TEST_TOKEN_SCOPED_FOR_TENANT_${_TEST_K2HR3_TENANT}_USER_${_TEST_K2HR3_USER}" --openstacktoken TEST_USER_OPENSTACK_SCOPED_TOKEN "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (10) Normal : Show slave configuration
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(10) Normal : Show slave configuration"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database show configuration slave "${_TEST_K2HDKC_CLUSTER_NAME}" --json --scopedtoken "TEST_TOKEN_SCOPED_FOR_TENANT_${_TEST_K2HR3_TENANT}_USER_${_TEST_K2HR3_USER}" --openstacktoken TEST_USER_OPENSTACK_SCOPED_TOKEN "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (11) Normal : Delete Cluster
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(11) Normal : Delete Cluster"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database delete cluster "${_TEST_K2HDKC_CLUSTER_NAME}" -y --scopedtoken "TEST_TOKEN_SCOPED_FOR_TENANT_${_TEST_K2HR3_TENANT}_USER_${_TEST_K2HR3_USER}" --openstacktoken TEST_USER_OPENSTACK_SCOPED_TOKEN "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (12) Normal : List Images
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(12) Normal : List Images"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database list images --openstacktoken TEST_USER_OPENSTACK_SCOPED_TOKEN --json "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (13) Normal : List Flavors
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(13) Normal : List Flavors"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database list flavors --openstacktoken TEST_USER_OPENSTACK_SCOPED_TOKEN --op_tenant "${_TEST_K2HR3_TENANT}" --json "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# Check update log
#---------------------------------------------------------------------
if ! test_update_snapshot; then
	TEST_EXIT_CODE=1
fi

exit ${TEST_EXIT_CODE}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
