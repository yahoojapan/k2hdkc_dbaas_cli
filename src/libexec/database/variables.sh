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
# DBaaS Valiables
#--------------------------------------------------------------
# The following values are used in the K2HDKC DBAAS CLI.
#
#	K2HR3CLI_DBAAS_CONFIG
#	K2HR3CLI_OPENSTACK_USER
#	K2HR3CLI_OPENSTACK_USER_ID
#	K2HR3CLI_OPENSTACK_PASS
#	K2HR3CLI_OPENSTACK_TENANT
#	K2HR3CLI_OPENSTACK_TENANT_ID
#	K2HR3CLI_OPENSTACK_SCOPED_TOKEN
#	K2HR3CLI_OPENSTACK_IDENTITY_URI
#	K2HR3CLI_OPENSTACK_NOVA_URI
#	K2HR3CLI_OPENSTACK_GLANCE_URI
#	K2HR3CLI_OPENSTACK_NEUTRON_URI
#

#--------------------------------------------------------------
# DBaaS Variables for Configration
#--------------------------------------------------------------
#
# Description
#
if [ -n "${K2HR3CLI_PLUGIN_CONFIG_VAR_DESC}" ]; then
	K2HR3CLI_PLUGIN_CONFIG_VAR_DESC="${K2HR3CLI_PLUGIN_CONFIG_VAR_DESC} config_var_desciption_dbaas"
else
	K2HR3CLI_PLUGIN_CONFIG_VAR_DESC="config_var_desciption_dbaas"
fi

#
# Names
#
if [ -n "${K2HR3CLI_PLUGIN_CONFIG_VAR_NAME}" ]; then
	K2HR3CLI_PLUGIN_CONFIG_VAR_NAME="${K2HR3CLI_PLUGIN_CONFIG_VAR_NAME} config_var_name_dbaas"
else
	K2HR3CLI_PLUGIN_CONFIG_VAR_NAME="config_var_name_dbaas"
fi

#
# Check DBaaS Variables
#
if [ -n "${K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR}" ]; then
	K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR="${K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR} config_check_var_name_dbaas"
else
	K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR="config_check_var_name_dbaas"
fi

#--------------------------------------------------------------
# Functions
#--------------------------------------------------------------
#
# Return variable description for this Example Plugin
#
# $?	: result
#
# [NOTE]
#           +---+----+----+----+----+----+----+----+----+----+----+----+----|
#           ^   ^
#           |   +--- Start for Description
#           +------- Start for Variables Title
#
config_var_desciption_dbaas()
{
	prn_msg "K2HR3CLI_DBAAS_CONFIG"
	prn_msg "   Specifies the DBaaS configuration directory path."
	prn_msg ""
	prn_msg "K2HR3CLI_OPENSTACK_USER"
	prn_msg "   Set the user name of OpenStack."
	prn_msg ""
	prn_msg "K2HR3CLI_OPENSTACK_USER_ID"
	prn_msg "   Set the user id of OpenStack."
	prn_msg ""
	prn_msg "K2HR3CLI_OPENSTACK_PASS"
	prn_msg "   Set the passphrase for the OpenStack user."
	prn_msg "   RECOMMEND THAT THIS VALUE IS NOT SET TO ADDRESS SECURITY"
	prn_msg "   VULNERABILITIES."
	prn_msg ""
	prn_msg "K2HR3CLI_OPENSTACK_TENANT"
	prn_msg "   Specify the available tenant for OpenStack. A Scoped Token"
	prn_msg "   will be issued to this tenant."
	prn_msg ""
	prn_msg "K2HR3CLI_OPENSTACK_TENANT_ID"
	prn_msg "   Specify the available tenant id for OpenStack."
	prn_msg ""
	prn_msg "K2HR3CLI_OPENSTACK_SCOPED_TOKEN"
	prn_msg "   Set the Scoped Token of OpenStack."
	prn_msg ""
	prn_msg "K2HR3CLI_OPENSTACK_IDENTITY_URI"
	prn_msg "   Specifies the OpenStack Identity URI."
	prn_msg ""
	prn_msg "K2HR3CLI_OPENSTACK_NOVA_URI"
	prn_msg "   Specifies the OpenStack Nova(Compute) URI."
	prn_msg ""
	prn_msg "K2HR3CLI_OPENSTACK_GLANCE_URI"
	prn_msg "   Specifies the OpenStack Glance(Images) URI."
	prn_msg ""
	prn_msg "K2HR3CLI_OPENSTACK_NEUTRON_URI"
	prn_msg "   Specifies the OpenStack Neutron(Network) URI."
	prn_msg ""
}

#
# Return variable name
#
# $1		: variable name(if empty, it means all)
# $?		: result
# Output	: variable names(with separator is space)
#
config_var_name_dbaas()
{
	if [ -z "$1" ]; then
		if [ -n "${K2HR3CLI_DBAAS_CONFIG}" ]; then
			prn_msg "K2HR3CLI_DBAAS_CONFIG: \"${K2HR3CLI_DBAAS_CONFIG}\""
		else
			prn_msg "K2HR3CLI_DBAAS_CONFIG: (empty)"
		fi
		if [ -n "${K2HR3CLI_OPENSTACK_USER}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_USER: \"${K2HR3CLI_OPENSTACK_USER}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_USER: (empty)"
		fi
		if [ -n "${K2HR3CLI_OPENSTACK_USER_ID}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_USER_ID: \"${K2HR3CLI_OPENSTACK_USER_ID}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_USER_ID: (empty)"
		fi
		if [ -n "${K2HR3CLI_OPENSTACK_PASS}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_PASS: \"********(${#K2HR3CLI_OPENSTACK_PASS})\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_PASS: (empty)"
		fi
		if [ -n "${K2HR3CLI_OPENSTACK_TENANT}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_TENANT: \"${K2HR3CLI_OPENSTACK_TENANT}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_TENANT: (empty)"
		fi
		if [ -n "${K2HR3CLI_OPENSTACK_TENANT_ID}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_TENANT_ID: \"${K2HR3CLI_OPENSTACK_TENANT_ID}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_TENANT_ID: (empty)"
		fi
		if [ -n "${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_SCOPED_TOKEN: \"${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_SCOPED_TOKEN: (empty)"
		fi
		if [ -n "${K2HR3CLI_OPENSTACK_IDENTITY_URI}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_IDENTITY_URI: \"${K2HR3CLI_OPENSTACK_IDENTITY_URI}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_IDENTITY_URI: (empty)"
		fi
		if [ -n "${K2HR3CLI_OPENSTACK_NOVA_URI}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_NOVA_URI: \"${K2HR3CLI_OPENSTACK_NOVA_URI}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_NOVA_URI: (empty)"
		fi
		if [ -n "${K2HR3CLI_OPENSTACK_GLANCE_URI}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_GLANCE_URI: \"${K2HR3CLI_OPENSTACK_GLANCE_URI}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_GLANCE_URI: (empty)"
		fi
		if [ -n "${K2HR3CLI_OPENSTACK_NEUTRON_URI}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_NEUTRON_URI: \"${K2HR3CLI_OPENSTACK_NEUTRON_URI}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_NEUTRON_URI: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_DBAAS_CONFIG" ]; then
		if [ -n "${K2HR3CLI_DBAAS_CONFIG}" ]; then
			prn_msg "K2HR3CLI_DBAAS_CONFIG: \"${K2HR3CLI_DBAAS_CONFIG}\""
		else
			prn_msg "K2HR3CLI_DBAAS_CONFIG: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_OPENSTACK_USER" ]; then
		if [ -n "${K2HR3CLI_OPENSTACK_USER}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_USER: \"${K2HR3CLI_OPENSTACK_USER}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_USER: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_OPENSTACK_USER_ID" ]; then
		if [ -n "${K2HR3CLI_OPENSTACK_USER_ID}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_USER_ID: \"${K2HR3CLI_OPENSTACK_USER_ID}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_USER_ID: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_OPENSTACK_PASS" ]; then
		if [ -n "${K2HR3CLI_OPENSTACK_PASS}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_PASS: \"${K2HR3CLI_OPENSTACK_PASS}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_PASS: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_OPENSTACK_TENANT" ]; then
		if [ -n "${K2HR3CLI_OPENSTACK_TENANT}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_TENANT: \"${K2HR3CLI_OPENSTACK_TENANT}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_TENANT: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_OPENSTACK_TENANT_ID" ]; then
		if [ -n "${K2HR3CLI_OPENSTACK_TENANT_ID}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_TENANT_ID: \"${K2HR3CLI_OPENSTACK_TENANT_ID}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_TENANT_ID: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_OPENSTACK_SCOPED_TOKEN" ]; then
		if [ -n "${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_SCOPED_TOKEN: \"${K2HR3CLI_OPENSTACK_SCOPED_TOKEN}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_SCOPED_TOKEN: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_OPENSTACK_IDENTITY_URI" ]; then
		if [ -n "${K2HR3CLI_OPENSTACK_IDENTITY_URI}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_IDENTITY_URI: \"${K2HR3CLI_OPENSTACK_IDENTITY_URI}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_IDENTITY_URI: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_OPENSTACK_NOVA_URI" ]; then
		if [ -n "${K2HR3CLI_OPENSTACK_NOVA_URI}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_NOVA_URI: \"${K2HR3CLI_OPENSTACK_NOVA_URI}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_NOVA_URI: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_OPENSTACK_GLANCE_URI" ]; then
		if [ -n "${K2HR3CLI_OPENSTACK_GLANCE_URI}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_GLANCE_URI: \"${K2HR3CLI_OPENSTACK_GLANCE_URI}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_GLANCE_URI: (empty)"
		fi
		return 0


	elif [ "$1" = "K2HR3CLI_OPENSTACK_NEUTRON_URI" ]; then
		if [ -n "${K2HR3CLI_OPENSTACK_NEUTRON_URI}" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_NEUTRON_URI: \"${K2HR3CLI_OPENSTACK_NEUTRON_URI}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_NEUTRON_URI: (empty)"
		fi
		return 0
	fi
	return 1
}

#
# Check variable name
#
# $1		: variable name
# $?		: result
#
config_check_var_name_dbaas()
{
	if [ -z "$1" ]; then
		return 1
	elif [ "$1" = "K2HR3CLI_DBAAS_CONFIG" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_OPENSTACK_USER" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_OPENSTACK_USER_ID" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_OPENSTACK_PASS" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_OPENSTACK_TENANT" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_OPENSTACK_TENANT_ID" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_OPENSTACK_SCOPED_TOKEN" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_OPENSTACK_IDENTITY_URI" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_OPENSTACK_NOVA_URI" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_OPENSTACK_GLANCE_URI" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_OPENSTACK_NEUTRON_URI" ]; then
		return 0
	fi
	return 1
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
